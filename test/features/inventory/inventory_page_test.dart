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

  for (final scale in [1.0, 1.3, 2.0]) {
    testWidgets('打印状态完整位于卡片内，字号 $scale', (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now().toUtc();
      final record = await repository.create(
        CreateMilkRecordCommand(
          storedAtUtc: now,
          timezoneOffsetMinutes: 480,
          amountMl: 180,
          storageMode: MilkStorageMode.frozen,
          createdAtUtc: now,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const InventoryPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(InventoryPage)),
      );
      for (final status in PrintStatus.values.where(
        (s) => s != PrintStatus.printed,
      )) {
        await repository.updatePrintStatus(
          id: record.id,
          status: status,
          updatedAtUtc: now,
        );
        container.invalidate(inventoryRecordsProvider);
        await tester.pumpAndSettle();
        final subtitle = find.textContaining('标签：');
        final card = find
            .ancestor(of: subtitle, matching: find.byType(Card))
            .first;
        expect(
          tester.getRect(subtitle).bottom,
          lessThanOrEqualTo(tester.getRect(card).bottom),
          reason: '$status at scale $scale',
        );
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('动态过期的详情仅提供丢弃操作', (tester) async {
    final now = DateTime.now().toUtc().subtract(const Duration(days: 400));
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 480,
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
    await tester.tap(find.text('180 mL · 已过期'));
    await tester.pumpAndSettle();
    expect(find.text('标记丢弃'), findsOneWidget);
    expect(find.text('开始解冻'), findsNothing);
    expect(find.text('整袋出库'), findsNothing);
    expect(find.text('180 mL · 已过期'), findsNWidgets(2));
    await tester.tap(find.text('标记丢弃'));
    await tester.pumpAndSettle();
    expect(
      (await repository.findById(record.id))?.status,
      MilkStatus.discarded,
    );
  });

  testWidgets('待打印筛选包括打印中、失败和内容更新，排除已打印', (tester) async {
    final now = DateTime.now().toUtc();
    final ids = <PrintStatus, String>{};
    for (final status in PrintStatus.values) {
      final record = await repository.create(
        CreateMilkRecordCommand(
          storedAtUtc: now.add(Duration(seconds: status.index)),
          timezoneOffsetMinutes: 480,
          amountMl: 100 + status.index,
          storageMode: MilkStorageMode.frozen,
          createdAtUtc: now,
        ),
      );
      ids[status] = record.id;
      await repository.updatePrintStatus(
        id: record.id,
        status: status,
        updatedAtUtc: now,
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const InventoryPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('待打印'));
    await tester.pumpAndSettle();
    expect(find.textContaining(ids[PrintStatus.printed]!), findsNothing);
    for (final status in PrintStatus.values.where(
      (s) => s != PrintStatus.printed,
    )) {
      await tester.scrollUntilVisible(
        find.textContaining(ids[status]!),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining(ids[status]!), findsOneWidget);
    }
  });

  testWidgets('真正空库存仍显示入库引导', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const InventoryPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('还没有库存记录'), findsOneWidget);
    expect(find.text('没有符合筛选条件的记录'), findsNothing);
  });

  testWidgets('状态与待打印组合及搜索无结果显示筛选提示', (tester) async {
    final now = DateTime.now().toUtc();
    final frozen = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 480,
        amountMl: 180,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
      ),
    );
    await repository.updatePrintStatus(
      id: frozen.id,
      status: PrintStatus.printed,
      updatedAtUtc: now,
    );
    await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now.add(const Duration(seconds: 1)),
        timezoneOffsetMinutes: 480,
        amountMl: 100,
        storageMode: MilkStorageMode.refrigerated,
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
    await tester.tap(find.text('冷冻在库'));
    await tester.tap(find.text('待打印'));
    await tester.pumpAndSettle();
    expect(find.text('没有符合筛选条件的记录'), findsOneWidget);
    expect(find.text('还没有库存记录'), findsNothing);
    await tester.tap(find.text('待打印'));
    await tester.pumpAndSettle();
    expect(find.text('180 mL · 冷冻在库'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no-match');
    await tester.pumpAndSettle();
    expect(find.text('没有符合筛选条件的记录'), findsOneWidget);
  });

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
