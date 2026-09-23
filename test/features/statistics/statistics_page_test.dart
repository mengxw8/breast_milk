import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/statistics/presentation/statistics_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('无数据显示空状态，有数据显示统计指标', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftMilkRepository(database);
    final now = DateTime.now().toUtc();
    await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 0,
        amountMl: 200,
        storageMode: MilkStorageMode.refrigerated,
        createdAtUtc: now,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('可用'), findsOneWidget);
    expect(find.textContaining('200 mL'), findsWidgets);
    expect(find.text('最近一周'), findsOneWidget);
    expect(find.textContaining('入库'), findsWidgets);
    expect(find.textContaining('出库'), findsWidgets);
  });

  testWidgets('全部出库后仍显示最近一周折线', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftMilkRepository(database);
    final now = DateTime.now().toUtc();
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: now.toLocal().timeZoneOffset.inMinutes,
        amountMl: 150,
        storageMode: MilkStorageMode.refrigerated,
        createdAtUtc: now,
      ),
    );
    await repository.transition(
      TransitionMilkRecordCommand(
        id: record.id,
        action: MilkAction.checkOut,
        occurredAtUtc: now,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('暂无统计数据'), findsNothing);
    expect(find.text('最近一周'), findsOneWidget);
    expect(find.text('入库 150 mL'), findsOneWidget);
    expect(find.text('出库 150 mL'), findsOneWidget);
    expect(find.textContaining('入库 150 mL · 出库 150 mL'), findsOneWidget);
  });
}
