import 'dart:convert';

import 'package:breast_milk/data/database/app_database.dart';

class SettingsStore {
  const SettingsStore(this.database);
  final AppDatabase database;

  Future<Map<String, dynamic>> read() async {
    final rows = await database.select(database.appSettings).get();
    return {for (final row in rows) row.key: jsonDecode(row.valueJson)};
  }

  Future<void> write(String key, Object value, DateTime nowUtc) async {
    await database
        .into(database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            valueJson: jsonEncode(value),
            updatedAtUtc: nowUtc,
          ),
        );
  }
}
