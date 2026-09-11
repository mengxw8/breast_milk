import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/features/settings/application/backup_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
