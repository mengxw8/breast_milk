import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/domain/services/expiry_policy.dart';
import 'package:breast_milk/features/settings/application/settings_store.dart';
import 'package:breast_milk/features/settings/presentation/settings_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('设置校验并持久化，新增记录使用新期限，已有记录期限保持不变', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftMilkRepository(database);
    final now = DateTime.utc(2026, 1, 31);
    CreateMilkRecordCommand command(MilkStorageMode mode) =>
        CreateMilkRecordCommand(
          storedAtUtc: now,
          timezoneOffsetMinutes: 480,
          amountMl: 120,
          storageMode: mode,
          createdAtUtc: now,
        );
    final original = await repository.create(command(MilkStorageMode.frozen));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light, home: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('保质期设置'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '3');
    await tester.enterText(fields.at(2), '6');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('请输入 1～365 的整数'), findsOneWidget);
    expect(find.text('最佳使用期不能超过冷冻保质期'), findsOneWidget);
    await tester.enterText(fields.at(0), '2');
    await tester.enterText(fields.at(2), '1');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('保质期设置已保存'), findsOneWidget);
    final settings = await SettingsStore(database).read();
    expect(settings['expiry.refrigeratedDays'], 2);
    expect(settings['expiry.frozenMonths'], 3);
    expect(settings['expiry.frozenBestUseMonths'], 1);
    final frozen = await repository.create(command(MilkStorageMode.frozen));
    expect(frozen.expiresAtUtc, DateTime.utc(2026, 4, 30));
    expect(frozen.bestUseAtUtc, DateTime.utc(2026, 2, 28));
    expect(
      const ExpiryPolicy().assessRecord(frozen, DateTime.utc(2026, 4, 1)),
      ExpiryRisk.finalExpirySoon,
    );
    final refrigerated = await repository.create(
      command(MilkStorageMode.refrigerated),
    );
    expect(refrigerated.expiresAtUtc, now.add(const Duration(days: 2)));
    expect(
      (await repository.findById(original.id))!.expiresAtUtc,
      original.expiresAtUtc,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
