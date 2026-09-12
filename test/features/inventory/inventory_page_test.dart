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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftMilkRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMilkRepository(database);
  });

  tearDown(() => database.close());

  testWidgets('冷冻在库按入库时间倒序排列', (tester) async {
    final older = DateTime.utc(2026, 9, 10, 10);
    final newer = DateTime.utc(2026, 9, 11, 10);
    await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: older,
        timezoneOffsetMinutes: 8 * 60,
        amountMl: 100,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: older,
      ),
    );
    await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: newer,
        timezoneOffsetMinutes: 8 * 60,
        amountMl: 200,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: newer,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const InventoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('200 mL · 冷冻在库')).dy,
      lessThan(tester.getTopLeft(find.text('100 mL · 冷冻在库')).dy),
    );
  });

  testWidgets('库存详情可以发送带重复打印标记的标签', (tester) async {
    const channel = MethodChannel('cn.mengxw.breast_milk/printer');
    MethodCall? printCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'printMilkLabel') printCall = call;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final now = DateTime.utc(2026, 9, 11, 10);
    await repository.create(
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
    await tester.tap(find.text('180 mL · 冷冻在库'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('重复打印条码'));
    await tester.pumpAndSettle();

    expect(printCall, isNotNull);
    final arguments = printCall!.arguments as Map<Object?, Object?>;
    final label = arguments['label'] as Map<Object?, Object?>;
    expect(label['reprint'], 'true');
    expect(find.text('重复打印标签已发送'), findsOneWidget);
  });

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
