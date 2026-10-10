import 'dart:async';
import 'dart:io';

import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryClockLiveUpdatesProvider = Provider<bool>(
  (ref) => Platform.environment['FLUTTER_TEST'] != 'true',
);
final inventoryNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final inventoryDataProvider = FutureProvider<List<MilkRecord>>((ref) {
  return ref.watch(milkRepositoryProvider).list(const MilkRecordFilter());
});

/// Shared by all mounted tabs: no minute polling and no timers in background.
final inventoryClockProvider = NotifierProvider<InventoryClock, DateTime>(
  InventoryClock.new,
);

class InventoryClock extends Notifier<DateTime> {
  @override
  DateTime build() {
    final readNow = ref.watch(inventoryNowProvider);
    final now = readNow().toUtc();
    // Drift schedules zero-delay cleanup timers in widget-test fake async zones.
    if (!ref.watch(inventoryClockLiveUpdatesProvider)) return now;
    final database = ref.watch(appDatabaseProvider);
    Timer? timer;
    var disposed = false;
    var rows = <MilkRecordRow>[];

    void schedule() {
      timer?.cancel();
      if (disposed ||
          (WidgetsBinding.instance.lifecycleState != null &&
              WidgetsBinding.instance.lifecycleState !=
                  AppLifecycleState.resumed)) {
        return;
      }
      final current = readNow();
      var next = DateTime(current.year, current.month, current.day + 1).toUtc();
      final utc = current.toUtc();
      for (final row in rows) {
        if (!row.status.isActive) continue;
        for (final boundary in [row.expiresAtUtc, row.bestUseAtUtc]) {
          if (boundary != null &&
              boundary.isAfter(utc) &&
              boundary.isBefore(next)) {
            next = boundary;
          }
        }
      }
      timer = Timer(next.difference(utc), () {
        state = readNow().toUtc();
        schedule();
      });
    }

    final lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          ref.invalidate(inventoryDataProvider);
          this.state = readNow().toUtc();
          schedule();
        } else {
          timer?.cancel();
        }
      },
    );
    final subscription = database.select(database.milkRecords).watch().listen((
      value,
    ) {
      rows = value;
      state = readNow().toUtc();
      ref.invalidate(inventoryDataProvider);
      schedule();
    });
    final links = database.select(database.milkFoodTags).watch().listen((_) {
      ref.invalidate(inventoryDataProvider);
    });
    schedule();
    ref.onDispose(() {
      disposed = true;
      timer?.cancel();
      lifecycle.dispose();
      subscription.cancel();
      links.cancel();
    });
    return now;
  }
}
