import 'dart:convert';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:drift/drift.dart';

class BackupService {
  const BackupService(this.database);
  final AppDatabase database;

  Future<String> exportJson() async {
    final records = await database.select(database.milkRecords).get();
    final events = await database.select(database.milkStatusEvents).get();
    final tags = await database.select(database.foodTags).get();
    return jsonEncode({
      'schemaVersion': 1,
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'records': records.map((row) => row.toJson()).toList(),
      'events': events.map((row) => row.toJson()).toList(),
      'foodTags': tags.map((row) => row.toJson()).toList(),
    });
  }

  Future<int> importJson(String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map || decoded['schemaVersion'] != 1) {
      throw const BackupFailure('unsupported_schema');
    }
    final records = _maps(decoded['records']);
    final events = _maps(decoded['events']);
    final tags = _maps(decoded['foodTags']);
    return database.transaction(() async {
      var count = 0;
      for (final tag in tags) {
        await database
            .into(database.foodTags)
            .insertOnConflictUpdate(
              FoodTagsCompanion.insert(
                id: tag['id'] as String,
                name: tag['name'] as String,
                createdAtUtc: _requiredDate(tag['createdAtUtc']),
                updatedAtUtc: _requiredDate(tag['updatedAtUtc']),
                lastUsedAtUtc: Value(_date(tag['lastUsedAtUtc'])),
                useCount: Value(tag['useCount'] as int? ?? 0),
              ),
            );
        count++;
      }
      for (final record in records) {
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
                updatedAtUtc: _requiredDate(record['updatedAtUtc']),
              ),
            );
        count++;
      }
      for (final event in events) {
        await database
            .into(database.milkStatusEvents)
            .insertOnConflictUpdate(
              MilkStatusEventsCompanion.insert(
                id: event['id'] as String,
                milkId: event['milkId'] as String,
                type: _enum(
                  event['type'] as String,
                  MilkStatusEventType.values,
                ),
                occurredAtUtc: _requiredDate(event['occurredAtUtc']),
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
      return count;
    });
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

  String _enumName<T extends Enum>(Object? value, List<T> values) =>
      value is int ? values[value].name : value.toString();
  T _enum<T extends Enum>(String name, List<T> values) => values.firstWhere(
    (value) => value.name == name,
    orElse: () => throw BackupFailure('invalid_enum_$name'),
  );

  T? _enumNullable<T extends Enum>(Object? value, List<T> values) =>
      value == null ? null : _enum(value as String, values);
}

class BackupFailure implements Exception {
  const BackupFailure(this.code);
  final String code;
}
