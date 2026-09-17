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
    private var discoveryReceiverRegistered = false
    private var connectionReceiverRegistered = false

    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device = intent.bluetoothDeviceExtra()
                    device?.let { emitDevice(it, false, intent) }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    emit("scan", "finished")
                }
            }
        }
    }

    private val connectionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    val device = intent.bluetoothDeviceExtra() ?: return
                    if (device.address.equals(connectedAddress, ignoreCase = true)) {
                        clearConnection(emitDisconnected = true)
                    }
                }
                BluetoothAdapter.ACTION_STATE_CHANGED -> {
                    val state = intent.getIntExtra(
                        BluetoothAdapter.EXTRA_STATE,
                        BluetoothAdapter.ERROR,
                    )
                    if (state == BluetoothAdapter.STATE_OFF ||
                        state == BluetoothAdapter.STATE_TURNING_OFF
                    ) {
                        clearConnection(emitDisconnected = true)
                    }
                }
                BluetoothDevice.ACTION_BOND_STATE_CHANGED -> {
                    val device = intent.bluetoothDeviceExtra() ?: return
                    val bondState = intent.getIntExtra(
                        BluetoothDevice.EXTRA_BOND_STATE,
                        BluetoothDevice.ERROR,
                    )
                    if (bondState == BluetoothDevice.BOND_NONE &&
                        device.address.equals(connectedAddress, ignoreCase = true)
                    ) {
                        clearConnection(emitDisconnected = true)
                    }
                }
            }
        }
    }

    init {
        POSConnect.init(activity.applicationContext)
        registerConnectionReceiver()
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
                    // Only accept success for the latest connect attempt.
                    if (connection !== nextConnection) return@connect
                    connectedAddress = address
                    emitConnection("connected", address)
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.success(Unit))
                    }
                }
                POSConnect.CONNECT_FAIL -> {
                    if (connection === nextConnection) {
                        connection = null
                        connectedAddress = null
                    }
                    emitConnection("connect_failed", address)
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.failure(PrinterException("connect_failed")))
                    }
                }
                POSConnect.CONNECT_INTERRUPT, POSConnect.BLUETOOTH_INTERRUPT -> {
                    if (connection === nextConnection ||
                        address.equals(connectedAddress, ignoreCase = true)
                    ) {
                        clearConnection(emitDisconnected = true, addressOverride = address)
                    }
                    if (completed.compareAndSet(false, true)) {
                        callback(Result.failure(PrinterException("connection_interrupted")))
                    }
                }
                POSConnect.SEND_FAIL -> emit("print", "send_failed")
            }
        }
    }

    fun disconnect() {
        clearConnection(emitDisconnected = true)
    }

    fun status(): Map<String, Any?> {
        val live = connection?.isConnect == true && !connectedAddress.isNullOrBlank()
        if (!live && (connection != null || connectedAddress != null)) {
            // Heal stale SDK state without double-emitting if already cleared.
            clearConnection(emitDisconnected = connectedAddress != null)
        }
        return mapOf(
            "bluetooth" to bluetoothState(),
            "connected" to (connection?.isConnect == true && !connectedAddress.isNullOrBlank()),
            "address" to connectedAddress,
        )
    }

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
        val isReprint = label["reprint"] == "true"
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
            if (isReprint) {
                printer.text(145, 18, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, "重复打印")
            }
            // 40x30mm @ ~8 dot/mm. Right-column text stays at x=145.
            // QR is kept left of x=145; id sits under QR with a gap from food (y=170).
            // Box right/bottom edges are inset slightly for print margin.
            printer
                .box(BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM, BOX_THICKNESS)
                .qrcode(
                    QR_X,
                    QR_Y,
                    TSPLConst.EC_LEVEL_M,
                    QR_CELL,
                    TSPLConst.QRCODE_MODE_AUTO,
                    TSPLConst.ROTATION_0,
                    id,
                )
                .text(145, 50, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("date"))
                .text(145, 80, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("time"))
                .text(145, 110, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("amount"))
                .text(145, 140, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("storage"))
                .text(145, 170, TSPLConst.FNT_SIMPLIFIED_CHINESE, 0, 1, 1, label.value("food"))
                .text(ID_X, ID_Y, TSPLConst.FNT_8_12, 0, 1, 1, id)
                .print(1)
            emit("print", "sent")
        } catch (error: Exception) {
            emit("print", "print_failed")
            throw PrinterException("print_failed", error)
        }
    }

    fun dispose() {
        stopScan()
        clearConnection(emitDisconnected = false)
        if (discoveryReceiverRegistered) {
            activity.unregisterReceiver(discoveryReceiver)
            discoveryReceiverRegistered = false
        }
        if (connectionReceiverRegistered) {
            activity.unregisterReceiver(connectionReceiver)
            connectionReceiverRegistered = false
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

    private fun clearConnection(
        emitDisconnected: Boolean,
        addressOverride: String? = null,
    ) {
        val previousAddress = addressOverride ?: connectedAddress
        try {
            connection?.close()
        } catch (_: Exception) {
            // Best-effort close; SDK may already be torn down.
        }
        connection = null
        connectedAddress = null
        if (emitDisconnected && previousAddress != null) {
            emitConnection("disconnected", previousAddress)
        }
    }

    private fun registerDiscoveryReceiver() {
        if (discoveryReceiverRegistered) return
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        registerReceiver(discoveryReceiver, filter)
        discoveryReceiverRegistered = true
    }

    private fun registerConnectionReceiver() {
        if (connectionReceiverRegistered) return
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        }
        registerReceiver(connectionReceiver, filter)
        connectionReceiverRegistered = true
    }

    private fun registerReceiver(receiver: BroadcastReceiver, filter: IntentFilter) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(receiver, filter)
        }
    }

    private fun Intent.bluetoothDeviceExtra(): BluetoothDevice? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }
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

        // Outer frame: keep left/top, pull right and bottom inward a little.
        private const val BOX_LEFT = 4
        private const val BOX_TOP = 4
        private const val BOX_RIGHT = 304 // was 316
        private const val BOX_BOTTOM = 222 // was 236, then 224
        private const val BOX_THICKNESS = 2

        // Slightly right of the old x=14 so QR sits closer to the content column
        // without crossing the text origin at x=145 (cell 5 ≈ 105–125 dots wide).
        private const val QR_X = 24
        private const val QR_Y = 40
        private const val QR_CELL = 5

        // Slightly above the old y=213; stays under food line (y=170, ~24pt high)
        // and above the box bottom (font 8x12 ends ~ ID_Y+12 < BOX_BOTTOM).
        private const val ID_X = 12
        private const val ID_Y = 200
    }
}

class PrinterException(
    val code: String,
    cause: Throwable? = null,
) : RuntimeException(code, cause)
