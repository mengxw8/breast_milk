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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const StatisticsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('可用'), findsOneWidget);
    expect(find.textContaining('200 mL'), findsWidgets);
  });
}
