package cn.mengxw.breast_milk.printer

import android.app.Activity
import android.media.AudioManager
import android.media.ToneGenerator
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PrinterChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
    private val launchEnableBluetooth: () -> Unit,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private val manager = PrinterManager(activity) { eventSink?.success(it) }

    private var eventSink: EventChannel.EventSink? = null
    private var permissionResult: MethodChannel.Result? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "hasPermissions" -> result.success(manager.hasPermissions())
                "requestPermissions" -> requestPermissions(result)
                "getBondedDevices" -> result.success(manager.bondedDevices())
                "startScan" -> {
                    manager.startScan()
                    result.success(null)
                }
                "stopScan" -> {
                    manager.stopScan()
                    result.success(null)
                }
                "connect" -> connect(call, result)
                "disconnect" -> {
                    manager.disconnect()
                    result.success(null)
                }
                "getStatus" -> result.success(manager.status())
                "playScanBeep" -> {
                    ToneGenerator(AudioManager.STREAM_NOTIFICATION, 85).startTone(ToneGenerator.TONE_PROP_BEEP, 120)
                    result.success(null)
                }
                "printTestLabel" -> {
                    manager.printTestLabel()
                    result.success(null)
                }
                "printMilkLabel" -> {
                    manager.printMilkLabel(call.stringMapArgument("label"))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (error: PrinterException) {
            result.error(error.code, null, null)
        } catch (error: SecurityException) {
            result.error("permissions_required", null, null)
        } catch (error: Exception) {
            result.error("printer_unavailable", error.message, null)
        }
    }

    fun onRequestPermissionsResult(requestCode: Int) {
        if (requestCode != PERMISSION_REQUEST_CODE) return
        val result = permissionResult ?: return
        if (!manager.hasPermissions()) {
            permissionResult = null
            result.success(false)
            return
        }
        try {
            ensureBluetoothEnabled(result)
        } catch (error: Exception) {
            permissionResult = null
            result.error((error as? PrinterException)?.code ?: "bluetooth_enable_failed", null, null)
        }
    }

    fun onBluetoothEnableResult(resultCode: Int) {
        val result = permissionResult ?: return
        permissionResult = null
        if (resultCode == Activity.RESULT_OK) {
            result.success(true)
        } else {
            result.error("bluetooth_enable_cancelled", null, null)
        }
    }

    fun dispose() {
        permissionResult?.error("activity_disposed", null, null)
        permissionResult = null
        eventSink = null
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        manager.dispose()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun requestPermissions(result: MethodChannel.Result) {
        if (permissionResult != null) {
            result.error("permission_request_in_progress", null, null)
            return
        }
        if (manager.hasPermissions()) {
            ensureBluetoothEnabled(result)
            return
        }
        permissionResult = result
        try {
            ActivityCompat.requestPermissions(activity, manager.requiredPermissions(), PERMISSION_REQUEST_CODE)
        } catch (error: Exception) {
            permissionResult = null
            throw error
        }
    }

    private fun ensureBluetoothEnabled(result: MethodChannel.Result) {
        when (manager.bluetoothState()) {
            "unavailable" -> throw PrinterException("bluetooth_unavailable")
            "enabled" -> {
                permissionResult = null
                result.success(true)
            }
            else -> {
                permissionResult = result
                try {
                    launchEnableBluetooth()
                } catch (error: Exception) {
                    permissionResult = null
                    throw PrinterException("bluetooth_enable_failed", error)
                }
            }
        }
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val address = call.argument<String>("address")
        if (address.isNullOrBlank()) {
            result.error("invalid_address", null, null)
            return
        }
        manager.connect(address) { connectionResult ->
            activity.runOnUiThread {
                connectionResult.fold(
                    onSuccess = { result.success(null) },
                    onFailure = {
                        val code = (it as? PrinterException)?.code ?: "connect_failed"
                        result.error(code, null, null)
                    },
                )
            }
        }
    }

    private fun MethodCall.stringMapArgument(name: String): Map<String, String> {
        val raw = argument<Map<*, *>>(name) ?: throw PrinterException("invalid_label")
        return raw.entries.associate { (key, value) ->
            key.toString() to value?.toString().orEmpty()
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "cn.mengxw.breast_milk/printer"
        private const val EVENT_CHANNEL = "cn.mengxw.breast_milk/printer_events"
        private const val PERMISSION_REQUEST_CODE = 2403
    }
}
