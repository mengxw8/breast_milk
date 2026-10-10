import 'dart:async';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/data/repositories/drift_milk_repository.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftMilkRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMilkRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('列表和待打印记录批量加载标签，不随记录数增加 SELECT 次数', () async {
    final logged = <String>[];
    await runZoned(
      () async {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(logStatements: true),
        );
        final repo = DriftMilkRepository(db);
        try {
          final now = DateTime.utc(2026, 10, 10);
          final tag = await repo.saveFoodTag(name: '鸡蛋', atUtc: now);
          for (var index = 0; index < 20; index++) {
            await repo.create(
              _createCommand(
                storedAtUtc: now.add(Duration(seconds: index)),
                createdAtUtc: now,
                foodTagIds: [tag.id],
              ),
            );
          }
          for (final load in [
            () => repo.list(const MilkRecordFilter()),
            repo.pendingPrints,
          ]) {
            logged.clear();
            final records = await load();
            expect(records, hasLength(20));
            expect(
              records.every((record) => record.foodTagIds.single == tag.id),
              isTrue,
            );
            expect(
              logged.where((line) => line.contains('SELECT ')),
              hasLength(2),
            );
          }
        } finally {
          await db.close();
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (_, _, _, line) => logged.add(line),
      ),
    );
  });

  test('同秒创建在事务中生成唯一编号并保存期限、标签和事件', () async {
    final now = DateTime.utc(2026, 9, 10, 4);
    final tag = await repository.saveFoodTag(name: '鸡蛋', atUtc: now);

    final first = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3, 57, 1),
        createdAtUtc: now,
        foodTagIds: [tag.id],
      ),
    );
    final second = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3, 57, 1),
        createdAtUtc: now.add(const Duration(microseconds: 1)),
      ),
    );

    expect(first.id, '2026091011570101');
    expect(second.id, '2026091011570102');
    expect(first.bestUseAtUtc, DateTime.utc(2027, 3, 10, 3, 57, 1));
    expect(first.expiresAtUtc, DateTime.utc(2027, 9, 10, 3, 57, 1));
    expect(first.foodTagIds, [tag.id]);
    expect(
      (await repository.eventsFor(first.id)).single.type,
      MilkStatusEventType.created,
    );
    final tags = await repository.listFoodTags();
    expect(tags.single.useCount, 1);
    expect(tags.single.lastUsedAtUtc, now);
  });

  test('无效食物标签使入库事务完整回滚且不占用编号', () async {
    final storedAt = DateTime.utc(2026, 9, 10, 3, 57, 1);
    final now = DateTime.utc(2026, 9, 10, 4);

    await expectLater(
      repository.create(
        _createCommand(
          storedAtUtc: storedAt,
          createdAtUtc: now,
          foodTagIds: const ['missing'],
        ),
      ),
      throwsA(
        isA<MilkRepositoryFailure>().having(
          (failure) => failure.code,
          'code',
          'food_tag_not_found',
        ),
      ),
    );

    final created = await repository.create(
      _createCommand(storedAtUtc: storedAt, createdAtUtc: now),
    );
    expect(created.id, '2026091011570101');
    expect((await repository.eventsFor(created.id)).length, 1);
  });

  test('数据库拒绝非正数奶量', () async {
    final now = DateTime.utc(2026, 9, 10);

    await expectLater(
      database
          .into(database.milkRecords)
          .insert(
            MilkRecordsCompanion.insert(
              id: '2026091012000001',
              storedAtUtc: now,
              timezoneOffsetMinutes: 480,
              amountMl: 0,
              storageMode: MilkStorageMode.frozen,
              status: MilkStatus.frozenInStock,
              expiresAtUtc: DateTime.utc(2027, 9, 10),
              printStatus: PrintStatus.notPrinted,
              expiryRuleVersion: 'test',
              createdAtUtc: now,
              updatedAtUtc: now,
            ),
          ),
      throwsA(anything),
    );
  });

  test('编辑已打印记录会标记标签需更新且保留标签使用次数', () async {
    final now = DateTime.utc(2026, 9, 10, 4);
    final tag = await repository.saveFoodTag(name: '牛奶', atUtc: now);
    final record = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3),
        createdAtUtc: now,
        foodTagIds: [tag.id],
      ),
    );
    await repository.updatePrintStatus(
      id: record.id,
      status: PrintStatus.printed,
      updatedAtUtc: now.add(const Duration(minutes: 1)),
    );

    final updated = await repository.update(
      UpdateMilkRecordCommand(
        id: record.id,
        storedAtUtc: record.storedAtUtc,
        timezoneOffsetMinutes: 480,
        amountMl: 150,
        storageMode: MilkStorageMode.refrigerated,
        foodTagIds: [tag.id],
        foodNotes: '少量咖啡',
        updatedAtUtc: now.add(const Duration(minutes: 2)),
      ),
    );

    expect(updated.amountMl, 150);
    expect(updated.status, MilkStatus.refrigeratedInStock);
    expect(updated.printStatus, PrintStatus.needsUpdate);
    expect(updated.bestUseAtUtc, isNull);
    expect(
      updated.expiresAtUtc,
      record.storedAtUtc.add(const Duration(hours: 96)),
    );
    expect((await repository.listFoodTags()).single.useCount, 1);
    expect((await repository.pendingPrints()).single.id, record.id);
  });

  test('删除常用食物仅从列表隐藏并保留记录关联', () async {
    final now = DateTime.utc(2026, 9, 10);
    final tag = await repository.saveFoodTag(name: '燕麦', atUtc: now);
    final record = await repository.create(
      _createCommand(storedAtUtc: now, createdAtUtc: now, foodTagIds: [tag.id]),
    );
    expect((await repository.findById(record.id))!.foodTagIds, [tag.id]);

    await repository.deleteFoodTag(tag.id);

    expect(await repository.listFoodTags(), isEmpty);
    expect((await repository.findById(record.id))!.foodTagIds, [tag.id]);
    final resolved = await repository.foodTagsByIds([tag.id]);
    expect(resolved.single.name, '燕麦');
    expect(resolved.single.isActive, isFalse);

    // Re-adding the same name restores the common list entry.
    final restored = await repository.saveFoodTag(name: '燕麦', atUtc: now);
    expect(restored.id, tag.id);
    expect(restored.isActive, isTrue);
    expect((await repository.listFoodTags()).single.id, tag.id);
  });

  test('按状态、储存方式、食物、时间和文本组合筛选并按期限排序', () async {
    final now = DateTime.utc(2026, 9, 10);
    final egg = await repository.saveFoodTag(name: '鸡蛋', atUtc: now);
    final first = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 9),
        createdAtUtc: now,
        storageMode: MilkStorageMode.frozen,
        foodTagIds: [egg.id],
      ),
    );
    final second = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10),
        createdAtUtc: now.add(const Duration(microseconds: 1)),
        storageMode: MilkStorageMode.refrigerated,
        foodTagIds: [egg.id],
        foodNotes: '燕麦',
      ),
    );

    final filtered = await repository.list(
      MilkRecordFilter(
        statuses: const {MilkStatus.refrigeratedInStock},
        storageModes: const {MilkStorageMode.refrigerated},
        foodTagIds: {egg.id},
        storedFromUtc: DateTime.utc(2026, 9, 10),
        storedUntilUtc: DateTime.utc(2026, 9, 11),
        searchText: '燕麦',
      ),
    );
    final all = await repository.list(const MilkRecordFilter());

    expect(filtered.map((record) => record.id), [second.id]);
    expect(all.first.id, second.id);
    expect(all.last.id, first.id);
  });

  test('解冻、出库和撤销在同一事务追加事件并恢复来源状态', () async {
    final now = DateTime.utc(2026, 9, 10, 4);
    final record = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3),
        createdAtUtc: now,
      ),
    );
    final thawed = await repository.transition(
      TransitionMilkRecordCommand(
        id: record.id,
        action: MilkAction.startThawing,
        occurredAtUtc: now.add(const Duration(hours: 1)),
      ),
    );
    expect(thawed.status, MilkStatus.thawing);
    expect(thawed.expiresAtUtc, now.add(const Duration(hours: 25)));

    final checkedOut = await repository.transition(
      TransitionMilkRecordCommand(
        id: record.id,
        action: MilkAction.checkOut,
        occurredAtUtc: now.add(const Duration(hours: 2)),
      ),
    );
    expect(checkedOut.status, MilkStatus.checkedOut);

    final restored = await repository.transition(
      TransitionMilkRecordCommand(
        id: record.id,
        action: MilkAction.undoCheckOut,
        occurredAtUtc: now.add(const Duration(hours: 3)),
      ),
    );
    expect(restored.status, MilkStatus.thawing);
    expect(restored.checkedOutAtUtc, isNull);
    expect((await repository.eventsFor(record.id)).map((event) => event.type), [
      MilkStatusEventType.created,
      MilkStatusEventType.thawingStarted,
      MilkStatusEventType.checkedOut,
      MilkStatusEventType.checkOutUndone,
    ]);
  });

  test('事件写入失败时状态更新一并回滚', () async {
    final now = DateTime.utc(2026, 9, 10, 4);
    final record = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3),
        createdAtUtc: now,
      ),
    );
    await database.customStatement('''
      CREATE TRIGGER reject_events
      BEFORE INSERT ON milk_status_events
      BEGIN
        SELECT RAISE(ABORT, 'test rollback');
      END
    ''');

    await expectLater(
      repository.transition(
        TransitionMilkRecordCommand(
          id: record.id,
          action: MilkAction.checkOut,
          occurredAtUtc: now.add(const Duration(hours: 1)),
        ),
      ),
      throwsA(anything),
    );

    expect(
      (await repository.findById(record.id))?.status,
      MilkStatus.frozenInStock,
    );
    expect((await repository.eventsFor(record.id)).length, 1);
  });

  test('状态机拒绝转换时映射为仓储错误', () async {
    final now = DateTime.utc(2026, 9, 10, 4);
    final record = await repository.create(
      _createCommand(
        storedAtUtc: DateTime.utc(2026, 9, 10, 3),
        createdAtUtc: now,
      ),
    );

    await expectLater(
      repository.transition(
        TransitionMilkRecordCommand(
          id: record.id,
          action: MilkAction.undoCheckOut,
          occurredAtUtc: now,
        ),
      ),
      throwsA(
        isA<MilkRepositoryFailure>().having(
          (error) => error.code,
          'code',
          'transition_not_allowed',
        ),
      ),
    );
  });
}

CreateMilkRecordCommand _createCommand({
  required DateTime storedAtUtc,
  required DateTime createdAtUtc,
  int amountMl = 120,
  MilkStorageMode storageMode = MilkStorageMode.frozen,
  List<String> foodTagIds = const [],
  String foodNotes = '',
}) {
  return CreateMilkRecordCommand(
    storedAtUtc: storedAtUtc,
    timezoneOffsetMinutes: 8 * 60,
    amountMl: amountMl,
    storageMode: storageMode,
    foodTagIds: foodTagIds,
    foodNotes: foodNotes,
    createdAtUtc: createdAtUtc,
  );
}
