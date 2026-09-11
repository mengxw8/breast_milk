import 'dart:io';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/features/settings/application/notification_service.dart';
import 'package:breast_milk/features/settings/application/settings_store.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final milkRepositoryProvider = Provider<MilkRepository>(
  (ref) => DriftMilkRepository(ref.watch(appDatabaseProvider)),
);

final notificationSyncProvider = Provider<void>((ref) {
  // Widget tests use fake async timers; the production stream is not needed there.
  if (Platform.environment['FLUTTER_TEST'] == 'true') return;
  final database = ref.watch(appDatabaseProvider);
  final subscription = database.select(database.milkRecords).watch().listen((
    records,
  ) async {
    final settings = await SettingsStore(database).read();
    if (settings['notifications.enabled'] != true) return;
    final now = DateTime.now().toUtc();
    final risks = records
        .where(
          (row) =>
              row.status == MilkStatus.thawing ||
              row.expiresAtUtc.isBefore(now),
        )
        .toList();
    final time = settings['notifications.time'] as String? ?? '09:00';
    final parts = time.split(':');
    final service = NotificationService();
    await service.initialize();
    await service.scheduleDaily(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last) ?? 0,
      riskCount: risks.length,
      totalMl: risks.fold(0, (sum, row) => sum + row.amountMl),
    );
  });
  ref.onDispose(subscription.cancel);
});
