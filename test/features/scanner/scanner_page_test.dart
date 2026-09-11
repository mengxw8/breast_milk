import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/scanner/presentation/scanner_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
