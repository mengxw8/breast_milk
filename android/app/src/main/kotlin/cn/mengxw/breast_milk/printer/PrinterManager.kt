package cn.mengxw.breast_milk.printer

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import net.posprinter.TSPLConst
import net.posprinter.TSPLPrinter
import java.util.concurrent.atomic.AtomicBoolean

@SuppressLint("MissingPermission")
class PrinterManager(
    private val activity: Activity,
    private val emitEvent: (Map<String, Any?>) -> Unit,
) {
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val manager = activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        manager?.adapter
    }

    private var connection: IDeviceConnection? = null
    private var connectedAddress: String? = null
    private var receiverRegistered = false

    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(
                            BluetoothDevice.EXTRA_DEVICE,
                            BluetoothDevice::class.java,
                        )
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }
                    device?.let { emitDevice(it, false, intent) }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    emit("scan", "finished")
                }
            }
        }
    }

    init {
        POSConnect.init(activity.applicationContext)
    }

    fun hasPermissions(): Boolean = requiredPermissions().all {
        ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
    }

    fun requiredPermissions(): Array<String> = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> arrayOf(
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT,
        )
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
        )
        else -> emptyArray()
    }

    fun bluetoothState(): String = when {
        bluetoothAdapter == null -> "unavailable"
        bluetoothAdapter?.isEnabled != true -> "disabled"
        else -> "enabled"
    }

    fun bondedDevices(): List<Map<String, Any?>> {
        requireBluetoothReady()
        return bluetoothAdapter.orEmptyBondedDevices()
            .sortedWith(compareBy({ it.name.orEmpty() }, { it.address }))
            .map { it.toMap(isBonded = true) }
    }

    fun startScan() {
        requireBluetoothReady()
        registerDiscoveryReceiver()
        bluetoothAdapter?.let { adapter ->
            if (adapter.isDiscovering) {
                adapter.cancelDiscovery()
            }
            if (!adapter.startDiscovery()) {
                throw PrinterException("scan_start_failed")
            }
        }
        emit("scan", "started")
    }

    fun stopScan() {
        if (hasPermissions() && bluetoothAdapter?.isDiscovering == true) {
            bluetoothAdapter?.cancelDiscovery()
        }
        emit("scan", "stopped")
    }

    fun connect(address: String, callback: (Result<Unit>) -> Unit) {
        requireBluetoothReady()
        if (!BluetoothAdapter.checkBluetoothAddress(address)) {
            callback(Result.failure(PrinterException("invalid_address")))
            return
        }

        stopScan()
        disconnect()
        emitConnection("connecting", address)

        val completed = AtomicBoolean(false)
        val nextConnection = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)
        connection = nextConnection
        nextConnection.connect(address) { code, _, _ ->
            when (code) {
                POSConnect.CONNECT_SUCCESS -> {
                    connectedAddress = address
                    emitConnection("connected", address)
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.success(Unit))
                    }
                }
                POSConnect.CONNECT_FAIL -> {
                    connectedAddress = null
                    emitConnection("connect_failed", address)
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.failure(PrinterException("connect_failed")))
                    }
                }
                POSConnect.CONNECT_INTERRUPT, POSConnect.BLUETOOTH_INTERRUPT -> {
                    connectedAddress = null
                    emitConnection("disconnected", address)
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.failure(PrinterException("connection_interrupted")))
                    }
                }
                POSConnect.SEND_FAIL -> emit("print", "send_failed")
            }
        }
    }

    fun disconnect() {
        connection?.close()
        connection = null
        val previousAddress = connectedAddress
        connectedAddress = null
        if (previousAddress != null) {
            emitConnection("disconnected", previousAddress)
        }
    }

    fun status(): Map<String, Any?> = mapOf(
        "bluetooth" to bluetoothState(),
        "connected" to (connection?.isConnect == true),
        "address" to connectedAddress,
    )

    fun printTestLabel() {
        printMilkLabel(
            mapOf(
                "id" to TEST_ID,
                "date" to "2026-09-10",
                "time" to "11:57",
                "amount" to "120 mL",
                "storage" to "冷冻 -21℃",
                "food" to "鸡蛋 牛奶",
            ),
        )
    }

    fun printMilkLabel(label: Map<String, String>) {
        val activeConnection = connection
        if (activeConnection?.isConnect != true) {
            throw PrinterException("not_connected")
        }

        val id = label.requiredValue("id")
        val printer = TSPLPrinter(activeConnection)
        try {
            emit("print", "printing")
            printer
                .sizeMm(LABEL_WIDTH_MM, LABEL_HEIGHT_MM)
                .gapMm(GAP_MM, 0.0)
                .speed(3.0)
                .density(8)
                .direction(1) // TSPL reverse direction rotates the label 180 degrees
                .reference(0, 0)
                .cls()
                .box(4, 4, 316, 236, 2)
                .qrcode(
                    14,
                    40,
                    TSPLConst.EC_LEVEL_M,
                    5,
                    TSPLConst.QRCODE_MODE_AUTO,
                    TSPLConst.ROTATION_0,
                    id,
                )
                .text(145, 50, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("date"))
                .text(145, 80, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("time"))
                .text(145, 110, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("amount"))
                .text(145, 140, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("storage"))
                .text(145, 170, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("food"))
                .text(12, 213, TSPLConst.FNT_8_12, 0, 1, 1, id)
                .print(1)
            emit("print", "sent")
        } catch (error: Exception) {
            emit("print", "print_failed")
            throw PrinterException("print_failed", error)
        }
    }

    fun dispose() {
        stopScan()
        disconnect()
        if (receiverRegistered) {
            activity.unregisterReceiver(discoveryReceiver)
            receiverRegistered = false
        }
        POSConnect.exit()
    }

    private fun requireBluetoothReady() {
        if (!hasPermissions()) {
            throw PrinterException("permissions_required")
        }
        when (bluetoothState()) {
            "unavailable" -> throw PrinterException("bluetooth_unavailable")
            "disabled" -> throw PrinterException("bluetooth_disabled")
        }
    }

    private fun registerDiscoveryReceiver() {
        if (receiverRegistered) return
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(discoveryReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(discoveryReceiver, filter)
        }
        receiverRegistered = true
    }

    private fun emitDevice(device: BluetoothDevice, isBonded: Boolean, intent: Intent) {
        val values = device.toMap(isBonded).toMutableMap()
        values["rssi"] = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, 0).toInt()
        activity.runOnUiThread {
            emitEvent(mapOf("type" to "device", "device" to values))
        }
    }

    private fun emit(type: String, state: String) {
        activity.runOnUiThread {
            emitEvent(mapOf("type" to type, "state" to state))
        }
    }

    private fun emitConnection(state: String, address: String?) {
        activity.runOnUiThread {
            emitEvent(
                mapOf(
                    "type" to "connection",
                    "state" to state,
                    "address" to address,
                ),
            )
        }
    }

    private fun BluetoothAdapter?.orEmptyBondedDevices(): Set<BluetoothDevice> =
        this?.bondedDevices ?: emptySet()

    private fun BluetoothDevice.toMap(isBonded: Boolean): Map<String, Any?> = mapOf(
        "name" to (name ?: "未命名设备"),
        "address" to address,
        "bonded" to isBonded,
    )

    private fun Map<String, String>.requiredValue(key: String): String {
        val result = value(key)
        if (result.isBlank()) throw PrinterException("invalid_label")
        return result
    }

    private fun Map<String, String>.value(key: String): String =
        this[key].orEmpty().replace(Regex("[\\r\\n]+"), " ").take(18)

    companion object {
        private const val LABEL_WIDTH_MM = 40.0
        private const val LABEL_HEIGHT_MM = 30.0
        private const val GAP_MM = 2.0
        private const val TEST_ID = "2026091011570101"
    }
}

class PrinterException(
    val code: String,
    cause: Throwable? = null,
) : RuntimeException(code, cause)
