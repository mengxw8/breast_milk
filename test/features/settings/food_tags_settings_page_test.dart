import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/features/settings/presentation/food_tags_settings_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('zh', 'CN')],
        home: const FoodTagsSettingsPage(),
      ),
    );
  }

  testWidgets('设置页可删除常用食物标签', (tester) async {
    await DriftMilkRepository(database).saveFoodTag(
      name: '鸡蛋',
      atUtc: DateTime.utc(2026, 9, 10),
    );
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('鸡蛋'), findsOneWidget);
    await tester.tap(find.byTooltip('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除常用食物'), findsOneWidget);
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.text('鸡蛋'), findsNothing);
    expect(await DriftMilkRepository(database).listFoodTags(), isEmpty);
  });
}
