import 'package:breast_milk/app/app.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/intake/presentation/intake_page.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:breast_milk/features/launch/presentation/brand_launch_page.dart';
import 'package:breast_milk/features/scanner/presentation/scanner_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  Widget shortcutTestApp() {
    final previousPlatform = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = _ShortcutScannerPlatform();
    MobileScannerController.resetPlatformSessionOwner();
    addTearDown(() {
      MobileScannerController.resetPlatformSessionOwner();
      MobileScannerPlatform.instance = previousPlatform;
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const BreastMilkApp(),
    );
  }

  testWidgets('桌面出库快捷入口冷启动直接进入扫码页', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        'breastmilk://app/scan';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(shortcutTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(ScannerPage), findsOneWidget);
    expect(find.text('扫码出库'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      ScannerPage.branchIndex,
    );
  });

  testWidgets('运行中的应用收到出库快捷入口后切换到扫码页', (tester) async {
    await tester.pumpWidget(shortcutTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('库存'));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryPage), findsOneWidget);

    await _openShortcut(tester, 'scan');
    expect(find.byType(ScannerPage), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      ScannerPage.branchIndex,
    );

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    await _openShortcut(tester, 'scan');
    expect(find.byType(ScannerPage), findsOneWidget);
    expect(find.text('扫码出库'), findsOneWidget);
  });

  testWidgets('桌面入库快捷入口冷启动直接进入入库页并可返回首页', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        'breastmilk://app/intake';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await tester.pumpWidget(shortcutTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(IntakePage), findsOneWidget);
    expect(find.text('母乳入库'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(IntakePage), findsNothing);
    expect(find.text('母乳库存管理'), findsOneWidget);
  });

  testWidgets('运行中的应用收到入库快捷入口后打开入库页且支持重复进入', (tester) async {
    await tester.pumpWidget(shortcutTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('库存'));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryPage), findsOneWidget);

    await _openShortcut(tester, 'intake');
    expect(find.byType(IntakePage), findsOneWidget);
    expect(find.text('母乳入库'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await _openShortcut(tester, 'intake');
    expect(find.byType(IntakePage), findsOneWidget);
    expect(find.text('母乳入库'), findsOneWidget);
  });

  testWidgets('启动时显示全屏品牌插画并自动进入首页', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreastMilkApp()));

    expect(find.byKey(BrandLaunchPage.pageKey), findsOneWidget);
    // The artwork is the whole splash - no logo lockup or tagline over it.
    final splash = tester.widget<Image>(
      find.descendant(
        of: find.byKey(BrandLaunchPage.pageKey),
        matching: find.byType(Image),
      ),
    );
    // May be AssetImage or ResizeImage(AssetImage) for decode-size optimization.
    final image = splash.image;
    final asset = image is ResizeImage ? image.imageProvider : image;
    expect(asset, isA<AssetImage>());
    expect((asset as AssetImage).assetName, BrandLaunchPage.assetName);
    // BoxFit.cover fills the screen without letterboxing or stretching.
    expect(splash.fit, BoxFit.cover);

    // Still holding mid-way through the splash.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(BrandLaunchPage.pageKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(BrandLaunchPage.pageKey), findsNothing);
    expect(find.text('母乳库存管理'), findsOneWidget);
  });

  testWidgets('应用从首页启动', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreastMilkApp()));
    await tester.pumpAndSettle();

    expect(find.text('吨吨吨'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('库存'), findsOneWidget);
    expect(find.text('扫码'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('主导航可切换并保持五个稳定入口', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreastMilkApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('库存'));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryPage), findsOneWidget);

    await tester.tap(find.text('扫码'));
    await tester.pumpAndSettle();
    expect(find.byType(ScannerPage), findsOneWidget);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.text('暂无统计数据'), findsOneWidget);

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('蓝牙打印机'), findsOneWidget);
  });

  testWidgets('小屏和大字体下主导航无溢出', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: ProviderScope(child: BreastMilkApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

Future<void> _openShortcut(WidgetTester tester, String path) async {
  final handled = tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(
      MethodCall('pushRouteInformation', {
        'location': 'breastmilk://app/$path',
      }),
    ),
    (_) {},
  );
  await tester.pumpAndSettle();
  await handled;
}

class _ShortcutScannerPlatform extends MobileScannerPlatform {
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const SizedBox.expand();
  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async {
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
      numberOfCameras: 1,
    );
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}
