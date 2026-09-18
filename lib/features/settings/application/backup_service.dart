import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:drift/drift.dart';

class BackupService {
  const BackupService(this.database, {this.persistPreImport = false});
  final AppDatabase database;
  final bool persistPreImport;

  Future<String> exportJson() async {
    final records = await database.select(database.milkRecords).get();
    final events = await database.select(database.milkStatusEvents).get();
    final tags = await database.select(database.foodTags).get();
    final milkFoodTags = await database.select(database.milkFoodTags).get();
    return jsonEncode({
      'schemaVersion': 1,
      // Marker for readers; payload itself is always UTF-8 on disk.
      'encoding': 'utf-8',
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'records': records.map((row) => row.toJson()).toList(),
      'events': events.map((row) => row.toJson()).toList(),
      'foodTags': tags.map((row) => row.toJson()).toList(),
      'milkFoodTags': milkFoodTags.map((row) => row.toJson()).toList(),
    });
  }

  /// UTF-8 bytes for writing a backup file.
  ///
  /// Never use [String.codeUnits] here — that truncates Chinese characters and
  /// produces invalid JSON on disk.
  Future<Uint8List> exportJsonBytes() async {
    return Uint8List.fromList(utf8.encode(await exportJson()));
  }

  /// Decode backup file bytes.
  ///
  /// Supports:
  /// - current UTF-8 exports
  /// - legacy exports that wrote truncated `String.codeUnits` as bytes
  ///   (may contain illegal control chars / dangling backslashes)
  static String decodeBackupBytes(List<int> bytes) {
    final candidates = <String>[];
    try {
      candidates.add(utf8.decode(bytes));
    } on FormatException {
      // ignore — try legacy decoders below
    }
    final latin1 = String.fromCharCodes(bytes);
    candidates
      ..add(latin1)
      ..add(_repairLegacyBackupText(latin1));

    for (final candidate in candidates) {
      try {
        final decoded = jsonDecode(candidate);
        if (decoded is Map) return candidate;
      } on FormatException {
        continue;
      }
    }
    throw const BackupFailure('invalid_json');
  }

  /// Repairs JSON damaged by legacy `codeUnits`→bytes exports.
  ///
  /// Truncated multi-byte characters can inject control bytes and a bare
  /// trailing `\` just before a real closing quote (`\","nextKey"`). Nested
  /// JSON in `metadataJson` uses legitimate `\"` and must be preserved.
  static String _repairLegacyBackupText(String input) {
    final out = StringBuffer();
    var inString = false;
    final units = input.codeUnits;
    const validEscapes = <int>{
      0x22, // "
      0x5c, // \
      0x2f, // /
      0x62, // b
      0x66, // f
      0x6e, // n
      0x72, // r
      0x74, // t
    };
    for (var i = 0; i < units.length; i++) {
      final code = units[i];
      if (!inString) {
        if (code == 0x22) inString = true;
        out.writeCharCode(code);
        continue;
      }

      // Strip illegal unescaped controls inside strings.
      if (code < 0x20 && code != 0x09 && code != 0x0a && code != 0x0d) {
        continue;
      }

      if (code == 0x5c) {
        if (i + 1 >= units.length) continue;
        final next = units[i + 1];
        if (next == 0x22) {
          final after = input.substring(i + 2);
          // Corruption: trailing \ before real close looks like \","key"
          // Nested JSON keeps \"} or \": forms.
          if (after.startsWith(',"')) {
            out.write('"');
            inString = false;
            i += 1;
            continue;
          }
          out.write(r'\"');
          i += 1;
          continue;
        }
        if (validEscapes.contains(next)) {
          out.writeCharCode(code);
          out.writeCharCode(next);
          i += 1;
          continue;
        }
        if (next == 0x75 && i + 5 < units.length) {
          out.write(input.substring(i, i + 6));
          i += 5;
          continue;
        }
        // Invalid escape: drop the backslash, keep following char.
        continue;
      }

      if (code == 0x22) {
        inString = false;
        out.write('"');
        continue;
      }
      out.writeCharCode(code);
    }
    return out.toString();
  }

  Future<int> importJson(String source) async {
    late final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const BackupFailure('invalid_json');
    }
    if (decoded is! Map || decoded['schemaVersion'] != 1) {
      throw const BackupFailure('unsupported_schema');
    }
    final records = _maps(decoded['records']);
    final events = _maps(decoded['events']);
    final tags = _maps(decoded['foodTags']);
    final milkFoodTags = _maps(decoded['milkFoodTags']);
    if (persistPreImport) {
      await _writePreImportBackup(await exportJson());
    }
    return database.transaction(() async {
      var count = 0;
      // imported food tag id -> local food tag id (name collisions remap)
      final tagIdMap = <String, String>{};

      for (final tag in tags) {
        final importedId = tag['id'] as String;
        final name = (tag['name'] as String).trim();
        if (name.isEmpty) continue;
        final importedUpdatedAt = _requiredDate(tag['updatedAtUtc']);
        final byId =
            await (database.select(database.foodTags)
                  ..where((row) => row.id.equals(importedId)))
                .getSingleOrNull();
        final byName =
            await (database.select(database.foodTags)
                  ..where((row) => row.name.equals(name)))
                .getSingleOrNull();

        if (byId != null) {
          tagIdMap[importedId] = byId.id;
          if (!importedUpdatedAt.isAfter(byId.updatedAtUtc)) continue;
          // Same id: refresh fields. Name change is skipped if another tag
          // already owns the target name.
          final nextName = byName == null || byName.id == byId.id
              ? name
              : byId.name;
          await (database.update(
            database.foodTags,
          )..where((row) => row.id.equals(byId.id))).write(
            FoodTagsCompanion(
              name: Value(nextName),
              updatedAtUtc: Value(importedUpdatedAt),
              lastUsedAtUtc: Value(_date(tag['lastUsedAtUtc'])),
              useCount: Value(tag['useCount'] as int? ?? byId.useCount),
              isActive: Value(tag['isActive'] as bool? ?? byId.isActive),
            ),
          );
          count++;
          continue;
        }

        if (byName != null) {
          // Same display name, different id: keep local id and remap links.
          tagIdMap[importedId] = byName.id;
          if (!importedUpdatedAt.isAfter(byName.updatedAtUtc)) continue;
          await (database.update(
            database.foodTags,
          )..where((row) => row.id.equals(byName.id))).write(
            FoodTagsCompanion(
              updatedAtUtc: Value(importedUpdatedAt),
              lastUsedAtUtc: Value(
                _date(tag['lastUsedAtUtc']) ?? byName.lastUsedAtUtc,
              ),
              useCount: Value(
                _maxInt(tag['useCount'] as int? ?? 0, byName.useCount),
              ),
              isActive: Value(tag['isActive'] as bool? ?? byName.isActive),
            ),
          );
          count++;
          continue;
        }

        tagIdMap[importedId] = importedId;
        await database
            .into(database.foodTags)
            .insert(
              FoodTagsCompanion.insert(
                id: importedId,
                name: name,
                createdAtUtc: _requiredDate(tag['createdAtUtc']),
                updatedAtUtc: importedUpdatedAt,
                lastUsedAtUtc: Value(_date(tag['lastUsedAtUtc'])),
                useCount: Value(tag['useCount'] as int? ?? 0),
                isActive: Value(tag['isActive'] as bool? ?? true),
              ),
            );
        count++;
      }

      for (final record in records) {
        final importedUpdatedAt = _requiredDate(record['updatedAtUtc']);
        final existing =
            await (database.select(database.milkRecords)
                  ..where((row) => row.id.equals(record['id'] as String)))
                .getSingleOrNull();
        if (existing != null &&
            !importedUpdatedAt.isAfter(existing.updatedAtUtc)) {
          continue;
        }
        await database
            .into(database.milkRecords)
            .insertOnConflictUpdate(
              MilkRecordsCompanion.insert(
                id: record['id'] as String,
                storedAtUtc: _requiredDate(record['storedAtUtc']),
                timezoneOffsetMinutes: record['timezoneOffsetMinutes'] as int,
                amountMl: record['amountMl'] as int,
                storageMode: _enum(
                  record['storageMode'] as String,
                  MilkStorageMode.values,
                ),
                foodNotes: Value(record['foodNotes'] as String? ?? ''),
                status: _enum(
                  _enumName(record['status'], MilkStatus.values),
                  MilkStatus.values,
                ),
                bestUseAtUtc: Value(_date(record['bestUseAtUtc'])),
                expiresAtUtc: _requiredDate(record['expiresAtUtc']),
                thawStartedAtUtc: Value(_date(record['thawStartedAtUtc'])),
                checkedOutAtUtc: Value(_date(record['checkedOutAtUtc'])),
                discardedAtUtc: Value(_date(record['discardedAtUtc'])),
                printStatus: _enum(
                  record['printStatus'] as String,
                  PrintStatus.values,
                ),
                lastPrintedAtUtc: Value(_date(record['lastPrintedAtUtc'])),
                expiryRuleVersion: record['expiryRuleVersion'] as String,
                createdAtUtc: _requiredDate(record['createdAtUtc']),
                updatedAtUtc: importedUpdatedAt,
              ),
            );
        count++;
      }

      for (final event in events) {
        final importedOccurredAt = _requiredDate(event['occurredAtUtc']);
        final existing =
            await (database.select(database.milkStatusEvents)
                  ..where((row) => row.id.equals(event['id'] as String)))
                .getSingleOrNull();
        if (existing != null &&
            !importedOccurredAt.isAfter(existing.occurredAtUtc)) {
          continue;
        }
        final milkId = event['milkId'] as String;
        final milkExists =
            await (database.select(database.milkRecords)
                  ..where((row) => row.id.equals(milkId)))
                .getSingleOrNull();
        if (milkExists == null) continue;
        await database
            .into(database.milkStatusEvents)
            .insertOnConflictUpdate(
              MilkStatusEventsCompanion.insert(
                id: event['id'] as String,
                milkId: milkId,
                type: _enum(
                  event['type'] as String,
                  MilkStatusEventType.values,
                ),
                occurredAtUtc: importedOccurredAt,
                fromStatus: Value(
                  _enumNullable(event['fromStatus'], MilkStatus.values),
                ),
                toStatus: _enum(
                  _enumName(event['toStatus'], MilkStatus.values),
                  MilkStatus.values,
                ),
                metadataJson: Value(event['metadataJson'] as String? ?? '{}'),
              ),
            );
      }

      for (final link in milkFoodTags) {
        final milkId = link['milkId'] as String;
        final importedTagId = link['foodTagId'] as String;
        final localTagId = tagIdMap[importedTagId] ?? importedTagId;
        final milkExists =
            await (database.select(database.milkRecords)
                  ..where((row) => row.id.equals(milkId)))
                .getSingleOrNull();
        final tagExists =
            await (database.select(database.foodTags)
                  ..where((row) => row.id.equals(localTagId)))
                .getSingleOrNull();
        if (milkExists == null || tagExists == null) continue;
        await database
            .into(database.milkFoodTags)
            .insertOnConflictUpdate(
              MilkFoodTagsCompanion.insert(
                milkId: milkId,
                foodTagId: localTagId,
              ),
            );
      }
      return count;
    });
  }

  Future<void> _writePreImportBackup(String json) async {
    final directory = await getApplicationSupportDirectory();
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final file = File(
      path.join(directory.path, 'backup-before-import-$stamp.json'),
    );
    await file.writeAsBytes(utf8.encode(json), flush: true);
  }

  List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];

  DateTime _requiredDate(Object? value) => value is int
      ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
      : DateTime.parse(value.toString());

  DateTime? _date(Object? value) => value == null ? null : _requiredDate(value);

  int _maxInt(int a, int b) => a > b ? a : b;

  String _enumName<T extends Enum>(Object? value, List<T> values) =>
      value is int ? values[value].name : value.toString();
  T _enum<T extends Enum>(String name, List<T> values) => values.firstWhere(
    (value) => value.name == name,
    orElse: () => throw BackupFailure('invalid_enum_$name'),
  );

  T? _enumNullable<T extends Enum>(Object? value, List<T> values) {
    if (value == null) return null;
    final name = value is String ? value : _enumName(value, values);
    return _enum(name, values);
  }
}

class BackupFailure implements Exception {
  const BackupFailure(this.code);
  final String code;
}
