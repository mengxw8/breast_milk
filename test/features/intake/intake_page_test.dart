import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/intake/presentation/intake_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildSubject({bool withPreviousPage = false}) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: withPreviousPage
            ? Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const IntakePage(),
                        ),
                      ),
                      child: const Text('打开入库'),
                    ),
                  ),
                ),
              )
            : const IntakePage(),
      ),
    );
  }

  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('默认奶量为 120 mL 并显示入库表单', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.text('母乳入库'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('保存并打印标签'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('保存并打印标签'), findsOneWidget);
    expect(find.text('仅保存，稍后打印'), findsOneWidget);
  });

  testWidgets('奶量为空时阻止保存', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.scrollUntilVisible(
      find.text('仅保存，稍后打印'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('仅保存，稍后打印'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextFormField).first,
      -500,
      scrollable: find.byType(Scrollable).last,
    );

    expect(
      await DriftMilkRepository(database).list(const MilkRecordFilter()),
      isEmpty,
    );
  });

  testWidgets('仅保存会写入真实数据库并返回上一页', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildSubject(withPreviousPage: true));

    await tester.tap(find.text('打开入库'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('仅保存，稍后打印'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('仅保存，稍后打印'));
    await tester.pumpAndSettle();

    final records = await DriftMilkRepository(database)
        .list(const MilkRecordFilter());
    expect(records, hasLength(1));
    expect(records.single.amountMl, 120);
    expect(records.single.storageMode, MilkStorageMode.frozen);
    expect(find.byType(IntakePage), findsNothing);
  });
}
