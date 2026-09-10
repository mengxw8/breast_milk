import 'package:breast_milk/app/app.dart';
import 'package:breast_milk/features/launch/presentation/brand_launch_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('启动时显示全屏品牌插画并自动进入首页', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreastMilkApp()));

    expect(find.byKey(BrandLaunchPage.pageKey), findsOneWidget);
    expect(find.text('每一袋，都安心有序'), findsOneWidget);

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
    expect(find.text('还没有库存记录'), findsOneWidget);

    await tester.tap(find.text('扫码'));
    await tester.pumpAndSettle();
    expect(find.text('对准标签二维码'), findsOneWidget);

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
