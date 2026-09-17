import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Platform gateway for backup JSON file pick/save.
///
/// On Android this uses an app-owned SAF channel. Both import and export go
/// through local UTF-8 cache files so Chinese text and large backups stay
/// intact (no truncated `codeUnits`, no fragile channel binary payloads).
class BackupFileGateway {
  BackupFileGateway({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('cn.mengxw.breast_milk/backup_files');

  final MethodChannel _channel;

  /// Opens the system file picker and returns the selected file bytes.
  ///
  /// Returns `null` when the user cancels.
  Future<Uint8List?> pickJsonBytes() async {
    if (kIsWeb) return null;
    try {
      final path = await _channel.invokeMethod<String>('pickJsonFile');
      if (path == null || path.isEmpty) return null;
      final file = File(path);
      if (!await file.exists()) {
        throw PlatformException(
          code: 'missing_cache_file',
          message: '临时文件不存在，请重试选择',
        );
      }
      final bytes = await file.readAsBytes();
      try {
        await file.delete();
      } catch (_) {}
      if (bytes.isEmpty) {
        throw PlatformException(
          code: 'empty_file',
          message: '所选文件为空',
        );
      }
      return bytes;
    } on MissingPluginException {
      return null;
    }
  }

  /// Saves UTF-8 JSON bytes through the system create-document picker.
  ///
  /// Writes a local temp file first, then asks native code to copy it into the
  /// user-selected SAF location. Returns `false` when the user cancels.
  Future<bool> saveJsonBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (kIsWeb) return false;
    if (bytes.isEmpty) {
      throw PlatformException(
        code: 'empty_export',
        message: '导出内容为空',
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/backup_export_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsBytes(bytes, flush: true);
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'saveJsonFile',
        <String, dynamic>{
          'path': file.path,
          'fileName': fileName,
        },
      );
      return result != null;
    } on MissingPluginException {
      return false;
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }
}
