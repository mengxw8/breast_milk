import 'dart:convert';
import 'dart:io';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/settings/application/backup_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('JSON 备份可往返导入并拒绝未知版本', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    final now = DateTime.utc(2026, 9, 11, 10);
    await DriftMilkRepository(source).create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 0,
        amountMl: 160,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
      ),
    );
    final json = await BackupService(source).exportJson();
    final count = await BackupService(target).importJson(json);
    expect(await BackupService(target).importJson(json), 0);
    expect(count, 1);
    expect(
      (await DriftMilkRepository(target).list(const MilkRecordFilter())),
      hasLength(1),
    );
    expect(
      () => BackupService(target).importJson('{"schemaVersion":99}'),
      throwsA(isA<BackupFailure>()),
    );
  });

  test('同名食物标签不同 id 可合并导入', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    final now = DateTime.utc(2026, 9, 11, 10);
    final sourceTag = await DriftMilkRepository(
      source,
    ).saveFoodTag(name: '燕麦', atUtc: now);
    final targetTag = await DriftMilkRepository(
      target,
    ).saveFoodTag(name: '燕麦', atUtc: now.add(const Duration(hours: 1)));
    final sourceRecord = await DriftMilkRepository(source).create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 480,
        amountMl: 120,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
        foodTagIds: [sourceTag.id],
      ),
    );

    final count = await BackupService(target).importJson(
      await BackupService(source).exportJson(),
    );
    expect(count, greaterThan(0));

    final tags = await DriftMilkRepository(target).listFoodTags();
    expect(tags, hasLength(1));
    expect(tags.single.name, '燕麦');
    expect(tags.single.id, targetTag.id);

    final records = await DriftMilkRepository(
      target,
    ).list(const MilkRecordFilter());
    expect(records.map((row) => row.id), contains(sourceRecord.id));

    final links = await target.select(target.milkFoodTags).get();
    expect(
      links.any(
        (link) =>
            link.milkId == sourceRecord.id && link.foodTagId == targetTag.id,
      ),
      isTrue,
    );
  });

  test('导出字节使用 UTF-8 且中文往返导入不损坏', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    final now = DateTime.utc(2026, 9, 11);
    final tag = await DriftMilkRepository(
      source,
    ).saveFoodTag(name: '燕麦粥', atUtc: now);
    await DriftMilkRepository(source).create(
      CreateMilkRecordCommand(
        storedAtUtc: now,
        timezoneOffsetMinutes: 480,
        amountMl: 90,
        storageMode: MilkStorageMode.frozen,
        createdAtUtc: now,
        foodTagIds: [tag.id],
        foodNotes: '早餐燕麦',
      ),
    );

    final bytes = await BackupService(source).exportJsonBytes();
    // 燕 in UTF-8 starts with 0xE7; codeUnits truncation would not produce this.
    expect(bytes, contains(0xe7));
    final decoded = BackupService.decodeBackupBytes(bytes);
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    expect(map['encoding'], 'utf-8');
    expect(decoded, contains('燕麦粥'));
    expect(decoded, contains('早餐燕麦'));

    final count = await BackupService(target).importJson(decoded);
    expect(count, greaterThan(0));
    final tags = await DriftMilkRepository(target).listFoodTags();
    expect(tags.single.name, '燕麦粥');
    final records = await DriftMilkRepository(
      target,
    ).list(const MilkRecordFilter());
    expect(records.single.foodNotes, '早餐燕麦');
  });

  test('可修复并导入旧版 codeUnits 损坏的备份文件', () async {
    final fixture = File(
      'test/features/settings/fixtures_legacy_codeunits_backup.bin',
    );
    expect(fixture.existsSync(), isTrue);
    final bytes = await fixture.readAsBytes();
    final decoded = BackupService.decodeBackupBytes(bytes);
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    expect(map['schemaVersion'], 1);
    expect((map['records'] as List).length, greaterThan(10));

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    final count = await BackupService(target).importJson(decoded);
    expect(count, greaterThan(0));
    final records = await DriftMilkRepository(
      target,
    ).list(const MilkRecordFilter());
    expect(records.length, greaterThan(10));
  });
}
