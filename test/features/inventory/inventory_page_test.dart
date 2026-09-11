import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftMilkRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMilkRepository(database);
  });

  tearDown(() => database.close());

  testWidgets('展示记录并支持搜索与详情操作', (tester) async {
    final now = DateTime.utc(2026, 9, 11, 10);
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 8 * 60,
        amountMl: 180,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const InventoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('180 mL · 冷冻在库'), findsOneWidget);
    await tester.enterText(find.byType(TextField), record.id);
    await tester.pump();
    expect(find.text('180 mL · 冷冻在库'), findsOneWidget);

    await tester.tap(find.text('180 mL · 冷冻在库'));
    await tester.pumpAndSettle();
    expect(find.text('库存详情'), findsOneWidget);
    expect(find.text('开始解冻'), findsOneWidget);
    await tester.tap(find.text('开始解冻'));
    await tester.pumpAndSettle();

    final updated = await repository.findById(record.id);
    expect(updated?.status, MilkStatus.thawing);
  });
}
