import 'dart:async';

import 'package:breast_milk/app/app_shell.dart';
import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/scanner/presentation/scanner_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('提供手动编号输入并显示扫码页', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ScannerPage()),
      ),
    );
    await tester.pump();
    expect(find.text('扫码出库'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('无法扫码？输入 16 位编号'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('无法扫码？输入 16 位编号'), findsOneWidget);
    expect(find.text('对准标签二维码'), findsOneWidget);
  });

  testWidgets('离开扫码分支后停止相机', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final platform = _FakeScannerPlatform();
    final previousPlatform = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = platform;
    MobileScannerController.resetPlatformSessionOwner();
    addTearDown(() async {
      MobileScannerController.resetPlatformSessionOwner();
      MobileScannerPlatform.instance = previousPlatform;
      await database.close();
    });

    final branch = ValueNotifier(ScannerPage.branchIndex);
    addTearDown(branch.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: ValueListenableBuilder<int>(
          valueListenable: branch,
          builder: (context, index, child) => ActiveBranchScope(
            index: index,
            child: const MaterialApp(home: ScannerPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(platform.startCount, 1);

    branch.value = 0;
    await tester.pumpAndSettle();

    expect(platform.stopCount, 1);

    branch.value = ScannerPage.branchIndex;
    await tester.pumpAndSettle();

    expect(platform.startCount, 2);
  });

  testWidgets('可以一键开关扫码闪光灯', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final platform = _FakeScannerPlatform();
    final previousPlatform = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = platform;
    MobileScannerController.resetPlatformSessionOwner();
    addTearDown(() async {
      MobileScannerController.resetPlatformSessionOwner();
      MobileScannerPlatform.instance = previousPlatform;
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ScannerPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('打开闪光灯'), findsOneWidget);
    await tester.tap(find.byTooltip('打开闪光灯'));
    await tester.pump();

    expect(platform.toggleTorchCount, 1);
    expect(find.byTooltip('关闭闪光灯'), findsOneWidget);
  });

  testWidgets('扫到已过期奶时弹出告警且不能出库', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftMilkRepository(database);
    final stored = DateTime.now().toUtc().subtract(const Duration(days: 5));
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: stored,
        timezoneOffsetMinutes: 0,
        amountMl: 180,
        storageMode: MilkStorageMode.refrigerated,
        createdAtUtc: stored,
      ),
    );
    final platform = _FakeScannerPlatform();
    final previousPlatform = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = platform;
    MobileScannerController.resetPlatformSessionOwner();
    addTearDown(() async {
      MobileScannerController.resetPlatformSessionOwner();
      MobileScannerPlatform.instance = previousPlatform;
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const ScannerPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('查询编号'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(find.byType(TextField), record.id);
    await tester.tap(find.text('查询编号'));
    await tester.pumpAndSettle();

    expect(find.text('该袋已过期'), findsOneWidget);
    expect(find.textContaining('已超过最终期限，不能出库'), findsOneWidget);
    expect(find.textContaining('编号：${record.id}'), findsOneWidget);
    expect(find.text('确认出库'), findsNothing);
    expect(find.text('知道了'), findsOneWidget);

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    expect(find.text('该袋已过期，不能出库'), findsOneWidget);
    expect(find.text('确认出库'), findsNothing);
    final saved = await repository.findById(record.id);
    expect(saved?.status, MilkStatus.refrigeratedInStock);
  });

  testWidgets('未过期奶仍进入普通出库确认', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftMilkRepository(database);
    final now = DateTime.now().toUtc();
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 0,
        amountMl: 120,
        storageMode: MilkStorageMode.refrigerated,
        createdAtUtc: now,
      ),
    );
    final platform = _FakeScannerPlatform();
    final previousPlatform = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = platform;
    MobileScannerController.resetPlatformSessionOwner();
    addTearDown(() async {
      MobileScannerController.resetPlatformSessionOwner();
      MobileScannerPlatform.instance = previousPlatform;
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const ScannerPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('查询编号'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(find.byType(TextField), record.id);
    await tester.tap(find.text('查询编号'));
    await tester.pumpAndSettle();

    expect(find.text('该袋已过期'), findsNothing);
    expect(find.text('确认整袋出库'), findsOneWidget);
    expect(find.text('确认出库'), findsOneWidget);
  });
}

class _FakeScannerPlatform extends MobileScannerPlatform {
  final _barcodes = StreamController<BarcodeCapture?>.broadcast();
  final _torch = StreamController<TorchState>.broadcast();
  int startCount = 0;
  int stopCount = 0;
  int toggleTorchCount = 0;

  @override
  Stream<BarcodeCapture?> get barcodesStream => _barcodes.stream;
  @override
  Stream<TorchState> get torchStateStream => _torch.stream;
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const ColoredBox(color: Colors.black);
  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async {
    startCount++;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
      numberOfCameras: 1,
    );
  }

  @override
  Future<void> stop() async => stopCount++;
  @override
  Future<void> toggleTorch() async {
    toggleTorchCount++;
    _torch.add(TorchState.on);
  }

  @override
  Future<void> dispose() async {
    await _barcodes.close();
    await _torch.close();
  }
}
