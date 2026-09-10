package cn.mengxw.breast_milk

import cn.mengxw.breast_milk.printer.PrinterChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var printerChannel: PrinterChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        printerChannel = PrinterChannel(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (::printerChannel.isInitialized) {
            printerChannel.onRequestPermissionsResult(requestCode)
        }
    }

    override fun onDestroy() {
        if (::printerChannel.isInitialized) {
            printerChannel.dispose()
        }
        super.onDestroy()
    }
}
