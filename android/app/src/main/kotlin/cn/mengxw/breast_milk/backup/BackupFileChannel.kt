package cn.mengxw.breast_milk.backup

import android.app.Activity
import android.content.ContentResolver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.OutputStream
import java.util.concurrent.Executors

/**
 * App-owned SAF channel for backup JSON import/export.
 *
 * Import/export both go through local cache files so large UTF-8 JSON never
 * depends on fragile MethodChannel binary transfers, and MIUI SAF quirks are
 * isolated to a simple stream copy.
 */
class BackupFileChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
    private val launchOpenDocument: (Array<String>) -> Unit,
    private val launchGetContent: (String) -> Unit,
    private val launchCreateDocument: (String) -> Unit,
) : MethodChannel.MethodCallHandler {
    private val methodChannel = MethodChannel(messenger, CHANNEL)
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    private var pendingResult: MethodChannel.Result? = null
    private var pendingSourcePath: String? = null
    private var pendingMode: Mode? = null

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickJsonFile" -> pickJson(result)
            "saveJsonFile" -> {
                val path = call.argument<String>("path")
                val fileName =
                    call.argument<String>("fileName") ?: "dun_dun_dun_backup.json"
                if (path.isNullOrBlank()) {
                    result.error("invalid_path", "path is required", null)
                    return
                }
                saveJsonFromPath(path, fileName, result)
            }
            // Backward-compatible alias used by older Dart builds.
            "saveJsonBytes" -> {
                val bytes = call.argument<ByteArray>("bytes")
                val fileName =
                    call.argument<String>("fileName") ?: "dun_dun_dun_backup.json"
                if (bytes == null) {
                    result.error("invalid_bytes", "bytes is required", null)
                    return
                }
                io.execute {
                    try {
                        val temp = writeTempExport(bytes)
                        main.post { saveJsonFromPath(temp.absolutePath, fileName, result) }
                    } catch (error: Exception) {
                        main.post {
                            result.error("write_failed", error.message, null)
                        }
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    fun onPickedUri(uri: Uri?) {
        val result = pendingResult
        val mode = pendingMode
        if (result == null || mode != Mode.OPEN) return

        if (uri == null) {
            clearPending()
            result.success(null)
            return
        }

        clearPending()
        io.execute {
            try {
                val path = copyUriToCache(uri)
                main.post { result.success(path) }
            } catch (error: Exception) {
                Log.e(TAG, "Failed to copy picked backup file", error)
                main.post {
                    result.error("read_failed", error.message ?: "读取文件失败", null)
                }
            }
        }
    }

    fun onCreatedUri(uri: Uri?) {
        val result = pendingResult
        val mode = pendingMode
        val sourcePath = pendingSourcePath
        clearPending()

        if (result == null || mode != Mode.CREATE) return
        if (uri == null) {
            result.success(null)
            return
        }
        if (sourcePath.isNullOrBlank()) {
            result.error("invalid_path", "export source missing", null)
            return
        }

        io.execute {
            try {
                val source = File(sourcePath)
                if (!source.exists() || source.length() <= 0L) {
                    throw IllegalStateException("导出临时文件不存在或为空")
                }
                copyFileToUri(source, uri)
                Log.i(
                    TAG,
                    "Exported backup ${source.length()} bytes to $uri",
                )
                main.post { result.success(uri.toString()) }
            } catch (error: Exception) {
                Log.e(TAG, "Failed to write backup file", error)
                main.post {
                    result.error("write_failed", error.message ?: "写入文件失败", null)
                }
            }
        }
    }

    fun dispose() {
        pendingResult?.error("activity_disposed", null, null)
        clearPending()
        methodChannel.setMethodCallHandler(null)
        io.shutdownNow()
    }

    private fun pickJson(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("already_active", "file operation already in progress", null)
            return
        }
        pendingResult = result
        pendingMode = Mode.OPEN
        try {
            launchGetContent("*/*")
        } catch (error: Exception) {
            Log.e(TAG, "GetContent launch failed, trying OpenDocument", error)
            try {
                launchOpenDocument(OPEN_MIME_TYPES)
            } catch (fallback: Exception) {
                clearPending()
                result.error("picker_unavailable", fallback.message, null)
            }
        }
    }

    private fun saveJsonFromPath(
        path: String,
        fileName: String,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error("already_active", "file operation already in progress", null)
            return
        }
        val source = File(path)
        if (!source.exists() || source.length() <= 0L) {
            result.error("invalid_path", "export source missing or empty", null)
            return
        }
        pendingResult = result
        pendingMode = Mode.CREATE
        pendingSourcePath = path
        try {
            launchCreateDocument(fileName)
        } catch (error: Exception) {
            clearPending()
            result.error("picker_unavailable", error.message, null)
        }
    }

    private fun writeTempExport(bytes: ByteArray): File {
        val dir = File(activity.cacheDir, "backup_export")
        if (!dir.exists() && !dir.mkdirs()) {
            throw IllegalStateException("无法创建导出临时目录")
        }
        val dest = File(dir, "export_${System.currentTimeMillis()}.json")
        FileOutputStream(dest).use { output ->
            output.write(bytes)
            output.fd.sync()
        }
        return dest
    }

    private fun copyUriToCache(uri: Uri): String {
        val resolver = activity.contentResolver
        val displayName = queryDisplayName(resolver, uri)
            ?.replace(Regex("""[\\/:*?"<>|]"""), "_")
            ?: "backup_import.json"
        val dir = File(activity.cacheDir, "backup_import")
        if (!dir.exists() && !dir.mkdirs()) {
            throw IllegalStateException("无法创建临时目录")
        }
        val dest = File(dir, "${System.currentTimeMillis()}_$displayName")
        resolver.openInputStream(uri).use { input ->
            if (input == null) {
                throw IllegalStateException("无法打开所选文件（权限或文件不可读）")
            }
            FileOutputStream(dest).use { output ->
                input.copyTo(output, bufferSize = 64 * 1024)
                output.fd.sync()
            }
        }
        if (!dest.exists() || dest.length() <= 0L) {
            throw IllegalStateException("文件复制失败或文件为空")
        }
        Log.i(TAG, "Copied backup to ${dest.absolutePath} (${dest.length()} bytes)")
        return dest.absolutePath
    }

    private fun copyFileToUri(source: File, uri: Uri) {
        openOutputStreamFlexible(uri).use { output ->
            FileInputStream(source).use { input ->
                input.copyTo(output, bufferSize = 64 * 1024)
                output.flush()
            }
        }
    }

    /**
     * Some SAF providers reject truncate modes like "wt". Try plain open first.
     */
    private fun openOutputStreamFlexible(uri: Uri): OutputStream {
        val resolver = activity.contentResolver
        val candidates = listOf(null, "w", "wt", "rwt")
        var lastError: Exception? = null
        for (mode in candidates) {
            try {
                val stream = if (mode == null) {
                    resolver.openOutputStream(uri)
                } else {
                    resolver.openOutputStream(uri, mode)
                }
                if (stream != null) return stream
            } catch (error: Exception) {
                lastError = error
                Log.w(TAG, "openOutputStream mode=$mode failed", error)
            }
        }
        throw lastError ?: IllegalStateException("无法写入所选位置")
    }

    private fun queryDisplayName(resolver: ContentResolver, uri: Uri): String? {
        return try {
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                ?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (index >= 0) cursor.getString(index) else null
                    } else {
                        null
                    }
                }
        } catch (_: Exception) {
            uri.lastPathSegment
        }
    }

    private fun clearPending() {
        pendingResult = null
        pendingSourcePath = null
        pendingMode = null
    }

    private enum class Mode { OPEN, CREATE }

    companion object {
        const val CHANNEL = "cn.mengxw.breast_milk/backup_files"
        private const val TAG = "BackupFileChannel"
        val OPEN_MIME_TYPES = arrayOf(
            "application/json",
            "text/json",
            "text/plain",
            "application/octet-stream",
            "*/*",
        )
    }
}
