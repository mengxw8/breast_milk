package cn.mengxw.breast_milk

import androidx.activity.result.contract.ActivityResultContracts
import cn.mengxw.breast_milk.backup.BackupFileChannel
import cn.mengxw.breast_milk.printer.PrinterChannel
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Uses [FlutterFragmentActivity] so AndroidX Activity Result APIs work for
 * reliable large-file backup import/export on MIUI.
 */
class MainActivity : FlutterFragmentActivity() {
    private lateinit var printerChannel: PrinterChannel
    private var backupFileChannel: BackupFileChannel? = null

    // Launchers must be registered before the Activity reaches STARTED.
    private val getContentLauncher =
        registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
            backupFileChannel?.onPickedUri(uri)
        }

    private val openDocumentLauncher =
        registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
            backupFileChannel?.onPickedUri(uri)
        }

    private val createDocumentLauncher =
        registerForActivityResult(
            ActivityResultContracts.CreateDocument("application/json"),
        ) { uri ->
            backupFileChannel?.onCreatedUri(uri)
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        printerChannel = PrinterChannel(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        backupFileChannel = BackupFileChannel(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
            launchOpenDocument = { mimeTypes -> openDocumentLauncher.launch(mimeTypes) },
            launchGetContent = { mimeType -> getContentLauncher.launch(mimeType) },
            launchCreateDocument = { fileName -> createDocumentLauncher.launch(fileName) },
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
        backupFileChannel?.dispose()
        backupFileChannel = null
        super.onDestroy()
    }
}
