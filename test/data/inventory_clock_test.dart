import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/database/inventory_clock.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:breast_milk/features/statistics/presentation/statistics_page.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('入库、出库和撤销出库后首页库存统计缓存同步更新', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.utc(2026, 10, 25, 12);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        inventoryClockLiveUpdatesProvider.overrideWithValue(true),
        inventoryNowProvider.overrideWithValue(() => now),
      ],
    );
    container.listen(homeInventorySummaryProvider, (_, _) {});
    container.listen(homeEarliestRecordProvider, (_, _) {});
    container.listen(inventoryRecordsProvider, (_, _) {});
    container.listen(statisticsSummaryProvider, (_, _) {});
    await tester.pumpAndSettle();
    expect(
      (await container.read(homeInventorySummaryProvider.future))
          .available
          .totalMl,
      0,
    );
    expect(await container.read(inventoryRecordsProvider.future), isEmpty);
    expect(
      (await container.read(statisticsSummaryProvider.future))
          .available
          .totalMl,
      0,
    );

    final repository = container.read(milkRepositoryProvider);
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 480,
        amountMl: 180,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      (await container.read(homeInventorySummaryProvider.future))
          .available
          .totalMl,
      180,
    );
    expect(
      (await container.read(statisticsSummaryProvider.future))
          .available
          .totalMl,
      180,
    );
    expect(
      (await container.read(homeEarliestRecordProvider.future))?.id,
      record.id,
    );
    expect(
      (await container.read(inventoryRecordsProvider.future)).single.status,
      MilkStatus.frozenInStock,
    );

    for (final action in [MilkAction.checkOut, MilkAction.undoCheckOut]) {
      await repository.transition(
        TransitionMilkRecordCommand(
          id: record.id,
          action: action,
          occurredAtUtc: now,
        ),
      );
      await tester.pumpAndSettle();
      final checkedOut = action == MilkAction.checkOut;
      final expectedMl = checkedOut ? 0 : 180;
      final home = await container.read(homeInventorySummaryProvider.future);
      final statistics = await container.read(statisticsSummaryProvider.future);
      expect(home.available.totalMl, expectedMl);
      expect(statistics.available.totalMl, expectedMl);
      expect(home.checkedOut.totalMl, checkedOut ? 180 : 0);
      expect(statistics.checkedOut.totalMl, checkedOut ? 180 : 0);
      expect(
        (await container.read(homeEarliestRecordProvider.future))?.id,
        checkedOut ? null : record.id,
      );
      expect(
        (await container.read(inventoryRecordsProvider.future)).single.status,
        checkedOut ? MilkStatus.checkedOut : MilkStatus.frozenInStock,
      );
    }
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });

  testWidgets('时钟仅在到期边界、零点、恢复前台刷新，后台停止计时', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    var now = DateTime(2026, 10, 10, 12);
    final start = now.toUtc();
    final repo = DriftMilkRepository(database);
    final record = await repo.create(
      CreateMilkRecordCommand(
        storedAtUtc: start,
        timezoneOffsetMinutes: 480,
        amountMl: 100,
        storageMode: MilkStorageMode.refrigerated,
        createdAtUtc: start,
      ),
    );
    await (database.update(
      database.milkRecords,
    )..where((row) => row.id.equals(record.id))).write(
      MilkRecordsCompanion(
        expiresAtUtc: Value(start.add(const Duration(minutes: 2))),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        inventoryClockLiveUpdatesProvider.overrideWithValue(true),
        inventoryNowProvider.overrideWithValue(() => now),
      ],
    );
    final ticks = <DateTime>[];
    container.listen(
      inventoryClockProvider,
      (_, next) => ticks.add(next),
      fireImmediately: true,
    );
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(ticks, hasLength(1));
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    expect(ticks.last, now.toUtc());
    expect(ticks, hasLength(2));
    now = DateTime(2026, 10, 11);
    await tester.pump(const Duration(hours: 11, minutes: 58));
    await tester.pumpAndSettle();
    expect(ticks.last, now.toUtc());
    final count = ticks.length;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(days: 2));
    await tester.pump(const Duration(days: 2));
    expect(ticks, hasLength(count));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(ticks.last, now.toUtc());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}
