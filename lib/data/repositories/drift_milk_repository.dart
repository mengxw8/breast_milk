import 'dart:convert';

import 'package:breast_milk/data/database/app_database.dart';
import 'package:breast_milk/domain/models/food_tag.dart' as domain;
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart' as domain;
import 'package:breast_milk/domain/models/milk_status_event.dart' as domain;
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/domain/services/expiry_policy.dart';
import 'package:breast_milk/domain/services/inventory_calculator.dart';
import 'package:breast_milk/domain/services/milk_id_generator.dart';
import 'package:breast_milk/domain/services/milk_state_machine.dart';
import 'package:drift/drift.dart';

class DriftMilkRepository implements MilkRepository {
  DriftMilkRepository(
    this.database, {
    this.idGenerator = const MilkIdGenerator(),
    this.expiryPolicy = const ExpiryPolicy(),
    this.stateMachine = const MilkStateMachine(),
  });

  final AppDatabase database;
  final MilkIdGenerator idGenerator;
  final ExpiryPolicy expiryPolicy;
  final MilkStateMachine stateMachine;

  @override
  Future<domain.MilkRecord> create(CreateMilkRecordCommand command) {
    _requireUtc(command.storedAtUtc);
    _requireUtc(command.createdAtUtc);
    if (command.amountMl <= 0) {
      throw const MilkRepositoryFailure('invalid_amount');
    }

    return database.transaction(() async {
      final localTime = command.storedAtUtc.add(
        Duration(minutes: command.timezoneOffsetMinutes),
      );
      final id = await idGenerator.generate(
        intakeLocalTime: localTime,
        exists: _idExists,
      );
      final window = expiryPolicy.forStorage(
        mode: command.storageMode,
        storedAtUtc: command.storedAtUtc,
        timezoneOffsetMinutes: command.timezoneOffsetMinutes,
      );
      final status = switch (command.storageMode) {
        MilkStorageMode.frozen => MilkStatus.frozenInStock,
        MilkStorageMode.refrigerated => MilkStatus.refrigeratedInStock,
      };

      await database
          .into(database.milkRecords)
          .insert(
            MilkRecordsCompanion.insert(
              id: id,
              storedAtUtc: command.storedAtUtc,
              timezoneOffsetMinutes: command.timezoneOffsetMinutes,
              amountMl: command.amountMl,
              storageMode: command.storageMode,
              foodNotes: Value(command.foodNotes.trim()),
              status: status,
              bestUseAtUtc: Value(window.bestUseAtUtc),
              expiresAtUtc: window.expiresAtUtc,
              printStatus: PrintStatus.notPrinted,
              expiryRuleVersion: window.ruleVersion,
              createdAtUtc: command.createdAtUtc,
              updatedAtUtc: command.createdAtUtc,
            ),
          );
      await _replaceFoodTags(id, command.foodTagIds, command.createdAtUtc);
      await _insertEvent(
        milkId: id,
        type: MilkStatusEventType.created,
        occurredAtUtc: command.createdAtUtc,
        from: null,
        to: status,
      );
      return _findRequired(id);
    });
  }

  @override
  Future<domain.MilkRecord?> findById(String id) async {
    final row = await (database.select(
      database.milkRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapRecord(row);
  }

  @override
  Future<List<domain.MilkRecord>> list(MilkRecordFilter filter) async {
    final query = database.select(database.milkRecords);
    if (filter.statuses.isNotEmpty) {
      query.where((table) => table.status.isInValues(filter.statuses));
    }
    if (filter.storageModes.isNotEmpty) {
      query.where((table) => table.storageMode.isInValues(filter.storageModes));
    }
    if (filter.storedFromUtc != null) {
      _requireUtc(filter.storedFromUtc!);
      query.where(
        (table) =>
            table.storedAtUtc.isBiggerOrEqualValue(filter.storedFromUtc!),
      );
    }
    if (filter.storedUntilUtc != null) {
      _requireUtc(filter.storedUntilUtc!);
      query.where(
        (table) => table.storedAtUtc.isSmallerThanValue(filter.storedUntilUtc!),
      );
    }

    final relatedMilkIds = <String>{};
    if (filter.foodTagIds.isNotEmpty) {
      final links = await (database.select(
        database.milkFoodTags,
      )..where((table) => table.foodTagId.isIn(filter.foodTagIds))).get();
      relatedMilkIds.addAll(links.map((link) => link.milkId));
      if (relatedMilkIds.isEmpty) return [];
      query.where((table) => table.id.isIn(relatedMilkIds));
    }

    final searchText = filter.searchText.trim();
    if (searchText.isNotEmpty) {
      final matchingTags = await (database.select(
        database.foodTags,
      )..where((table) => table.name.contains(searchText))).get();
      if (matchingTags.isNotEmpty) {
        final tagIds = matchingTags.map((tag) => tag.id).toSet();
        final links = await (database.select(
          database.milkFoodTags,
        )..where((table) => table.foodTagId.isIn(tagIds))).get();
        relatedMilkIds.addAll(links.map((link) => link.milkId));
      }
      query.where(
        (table) =>
            table.id.contains(searchText) |
            table.foodNotes.contains(searchText) |
            table.id.isIn(relatedMilkIds),
      );
    }

    query.orderBy([
      (table) => OrderingTerm.asc(table.expiresAtUtc),
      (table) => OrderingTerm.desc(table.storedAtUtc),
    ]);
    final rows = await query.get();
    return Future.wait(rows.map(_mapRecord));
  }

  @override
  Future<domain.MilkRecord> update(UpdateMilkRecordCommand command) {
    _requireUtc(command.storedAtUtc);
    _requireUtc(command.updatedAtUtc);
    if (command.amountMl <= 0) {
      throw const MilkRepositoryFailure('invalid_amount');
    }

    return database.transaction(() async {
      final current = await _findRowRequired(command.id);
      if (current.status != MilkStatus.frozenInStock &&
          current.status != MilkStatus.refrigeratedInStock) {
        throw const MilkRepositoryFailure('edit_not_allowed');
      }
      final window = expiryPolicy.forStorage(
        mode: command.storageMode,
        storedAtUtc: command.storedAtUtc,
        timezoneOffsetMinutes: command.timezoneOffsetMinutes,
      );
      final status = switch (command.storageMode) {
        MilkStorageMode.frozen => MilkStatus.frozenInStock,
        MilkStorageMode.refrigerated => MilkStatus.refrigeratedInStock,
      };
      final nextPrintStatus = current.printStatus == PrintStatus.printed
          ? PrintStatus.needsUpdate
          : current.printStatus;

      await (database.update(
        database.milkRecords,
      )..where((table) => table.id.equals(command.id))).write(
        MilkRecordsCompanion(
          storedAtUtc: Value(command.storedAtUtc),
          timezoneOffsetMinutes: Value(command.timezoneOffsetMinutes),
          amountMl: Value(command.amountMl),
          storageMode: Value(command.storageMode),
          foodNotes: Value(command.foodNotes.trim()),
          status: Value(status),
          bestUseAtUtc: Value(window.bestUseAtUtc),
          expiresAtUtc: Value(window.expiresAtUtc),
          printStatus: Value(nextPrintStatus),
          expiryRuleVersion: Value(window.ruleVersion),
          updatedAtUtc: Value(command.updatedAtUtc),
        ),
      );
      await _replaceFoodTags(
        command.id,
        command.foodTagIds,
        command.updatedAtUtc,
      );
      return _findRequired(command.id);
    });
  }

  @override
  Future<domain.MilkRecord> transition(TransitionMilkRecordCommand command) {
    _requireUtc(command.occurredAtUtc);
    return database.transaction(() async {
      final current = await _findRowRequired(command.id);
      MilkStatus? restoreStatus;
      if (command.action == MilkAction.undoCheckOut) {
        restoreStatus = await _checkoutOrigin(command.id);
      }
      final transition = stateMachine.transition(
        currentStatus: current.status,
        action: command.action,
        atUtc: command.occurredAtUtc,
        expiresAtUtc: current.expiresAtUtc.toUtc(),
        restoreStatus: restoreStatus,
      );
      final update = _transitionUpdate(current, transition);
      await (database.update(
        database.milkRecords,
      )..where((table) => table.id.equals(command.id))).write(update);
      await _insertEvent(
        milkId: command.id,
        type: transition.eventType,
        occurredAtUtc: command.occurredAtUtc,
        from: transition.from,
        to: transition.to,
        metadata: command.action == MilkAction.checkOut
            ? {'restoreStatus': current.status.name}
            : const {},
      );
      return _findRequired(command.id);
    });
  }

  @override
  Future<void> deleteById(String id) async {
    final deleted = await (database.delete(
      database.milkRecords,
    )..where((table) => table.id.equals(id))).go();
    if (deleted == 0) throw const MilkRepositoryFailure('record_not_found');
  }

  @override
  Future<void> updatePrintStatus({
    required String id,
    required PrintStatus status,
    required DateTime updatedAtUtc,
  }) async {
    _requireUtc(updatedAtUtc);
    final changed =
        await (database.update(
          database.milkRecords,
        )..where((table) => table.id.equals(id))).write(
          MilkRecordsCompanion(
            printStatus: Value(status),
            lastPrintedAtUtc: status == PrintStatus.printed
                ? Value(updatedAtUtc)
                : const Value.absent(),
            updatedAtUtc: Value(updatedAtUtc),
          ),
        );
    if (changed == 0) throw const MilkRepositoryFailure('record_not_found');
  }

  @override
  Future<List<domain.MilkRecord>> pendingPrints() async {
    final rows =
        await (database.select(database.milkRecords)
              ..where(
                (table) => table.printStatus.isInValues({
                  PrintStatus.notPrinted,
                  PrintStatus.failed,
                  PrintStatus.needsUpdate,
                }),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAtUtc)]))
            .get();
    return Future.wait(rows.map(_mapRecord));
  }

  @override
  Future<List<domain.MilkStatusEvent>> eventsFor(String milkId) async {
    final rows =
        await (database.select(database.milkStatusEvents)
              ..where((table) => table.milkId.equals(milkId))
              ..orderBy([(table) => OrderingTerm.asc(table.occurredAtUtc)]))
            .get();
    return rows.map(_mapEvent).toList(growable: false);
  }

  @override
  Future<domain.MilkRecord?> earliestUsable(DateTime nowUtc) async {
    _requireUtc(nowUtc);
    final row =
        await (database.select(database.milkRecords)
              ..where(
                (table) =>
                    table.status.isInValues({
                      MilkStatus.frozenInStock,
                      MilkStatus.refrigeratedInStock,
                      MilkStatus.thawing,
                    }) &
                    table.expiresAtUtc.isBiggerThanValue(nowUtc),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.expiresAtUtc)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _mapRecord(row);
  }

  @override
  Future<InventorySummary> inventorySummary(DateTime nowUtc) async {
    _requireUtc(nowUtc);
    final row = await database
        .customSelect(
          '''
      SELECT
        COALESCE(SUM(CASE WHEN status IN (?, ?, ?) AND expires_at_utc > ? THEN 1 ELSE 0 END), 0) AS available_bags,
        COALESCE(SUM(CASE WHEN status IN (?, ?, ?) AND expires_at_utc > ? THEN amount_ml ELSE 0 END), 0) AS available_ml,
        COALESCE(SUM(CASE WHEN status IN (?, ?, ?, ?) THEN 1 ELSE 0 END), 0) AS physical_bags,
        COALESCE(SUM(CASE WHEN status IN (?, ?, ?, ?) THEN amount_ml ELSE 0 END), 0) AS physical_ml,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN 1 ELSE 0 END), 0) AS frozen_bags,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN amount_ml ELSE 0 END), 0) AS frozen_ml,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN 1 ELSE 0 END), 0) AS refrigerated_bags,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN amount_ml ELSE 0 END), 0) AS refrigerated_ml,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN 1 ELSE 0 END), 0) AS thawing_bags,
        COALESCE(SUM(CASE WHEN status = ? AND expires_at_utc > ? THEN amount_ml ELSE 0 END), 0) AS thawing_ml,
        COALESCE(SUM(CASE WHEN status = ? OR (status IN (?, ?, ?) AND expires_at_utc <= ?) THEN 1 ELSE 0 END), 0) AS expired_bags,
        COALESCE(SUM(CASE WHEN status = ? OR (status IN (?, ?, ?) AND expires_at_utc <= ?) THEN amount_ml ELSE 0 END), 0) AS expired_ml,
        COALESCE(SUM(CASE WHEN status = ? THEN 1 ELSE 0 END), 0) AS checked_out_bags,
        COALESCE(SUM(CASE WHEN status = ? THEN amount_ml ELSE 0 END), 0) AS checked_out_ml,
        COALESCE(SUM(CASE WHEN status = ? THEN 1 ELSE 0 END), 0) AS discarded_bags,
        COALESCE(SUM(CASE WHEN status = ? THEN amount_ml ELSE 0 END), 0) AS discarded_ml
      FROM milk_records
      ''',
          variables: _summaryVariables(nowUtc),
          readsFrom: {database.milkRecords},
        )
        .getSingle();

    InventoryMetric metric(String prefix) => InventoryMetric(
      bagCount: row.read<int>('${prefix}_bags'),
      totalMl: row.read<int>('${prefix}_ml'),
    );

    return InventorySummary(
      available: metric('available'),
      physical: metric('physical'),
      frozen: metric('frozen'),
      refrigerated: metric('refrigerated'),
      thawing: metric('thawing'),
      expired: metric('expired'),
      checkedOut: metric('checked_out'),
      discarded: metric('discarded'),
    );
  }

  @override
  Future<domain.FoodTag> saveFoodTag({
    required String name,
    required DateTime atUtc,
  }) async {
    _requireUtc(atUtc);
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw const MilkRepositoryFailure('invalid_food_tag');
    }
    final existing = await (database.select(
      database.foodTags,
    )..where((table) => table.name.equals(normalizedName))).getSingleOrNull();
    if (existing != null) {
      if (existing.isActive) return _mapFoodTag(existing);
      // Re-adding a soft-deleted name restores it to the common list.
      await (database.update(
        database.foodTags,
      )..where((table) => table.id.equals(existing.id))).write(
        FoodTagsCompanion(
          isActive: const Value(true),
          updatedAtUtc: Value(atUtc),
        ),
      );
      final restored = await (database.select(
        database.foodTags,
      )..where((table) => table.id.equals(existing.id))).getSingle();
      return _mapFoodTag(restored);
    }

    var sequence = 0;
    String id;
    do {
      id = 'food_${atUtc.microsecondsSinceEpoch}_$sequence';
      sequence++;
    } while (await _foodTagIdExists(id));
    await database
        .into(database.foodTags)
        .insert(
          FoodTagsCompanion.insert(
            id: id,
            name: normalizedName,
            createdAtUtc: atUtc,
            updatedAtUtc: atUtc,
            isActive: const Value(true),
          ),
        );
    final created = await (database.select(
      database.foodTags,
    )..where((table) => table.id.equals(id))).getSingle();
    return _mapFoodTag(created);
  }

  @override
  Future<void> deleteFoodTag(String id) async {
    // Soft-delete only: keep milk_food_tags so historical records retain labels.
    final updated = await (database.update(
      database.foodTags,
    )..where((table) => table.id.equals(id) & table.isActive.equals(true)))
        .write(
      FoodTagsCompanion(
        isActive: const Value(false),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
    if (updated == 0) {
      final exists = await (database.select(
        database.foodTags,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (exists == null) {
        throw const MilkRepositoryFailure('food_tag_not_found');
      }
      // Already inactive — treat as success for idempotent UI deletes.
    }
  }

  @override
  Future<List<domain.FoodTag>> listFoodTags() async {
    final rows =
        await (database.select(database.foodTags)
              ..where((table) => table.isActive.equals(true))
              ..orderBy([
                (table) => OrderingTerm.desc(table.lastUsedAtUtc),
                (table) => OrderingTerm.desc(table.useCount),
                (table) => OrderingTerm.asc(table.name),
              ]))
            .get();
    return rows.map(_mapFoodTag).toList(growable: false);
  }

  @override
  Future<List<domain.FoodTag>> foodTagsByIds(Iterable<String> ids) async {
    final idList = ids.toSet().toList(growable: false);
    if (idList.isEmpty) return const [];
    final rows = await (database.select(
      database.foodTags,
    )..where((table) => table.id.isIn(idList))).get();
    final byId = {for (final row in rows) row.id: row};
    return idList
        .where(byId.containsKey)
        .map((id) => _mapFoodTag(byId[id]!))
        .toList(growable: false);
  }

  Future<bool> _idExists(String id) async {
    final row = await (database.select(
      database.milkRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row != null;
  }

  List<Variable<Object>> _summaryVariables(DateTime nowUtc) {
    final active = [
      MilkStatus.frozenInStock.name,
      MilkStatus.refrigeratedInStock.name,
      MilkStatus.thawing.name,
    ];
    final physical = [...active, MilkStatus.expired.name];
    final variables = <Variable<Object>>[];

    void addStrings(Iterable<String> values) {
      variables.addAll(values.map(Variable.withString));
    }

    void addTime() => variables.add(Variable.withDateTime(nowUtc));

    addStrings(active);
    addTime();
    addStrings(active);
    addTime();
    addStrings(physical);
    addStrings(physical);
    for (final status in active) {
      variables.add(Variable.withString(status));
      addTime();
      variables.add(Variable.withString(status));
      addTime();
    }
    variables.add(Variable.withString(MilkStatus.expired.name));
    addStrings(active);
    addTime();
    variables.add(Variable.withString(MilkStatus.expired.name));
    addStrings(active);
    addTime();
    variables.addAll([
      Variable.withString(MilkStatus.checkedOut.name),
      Variable.withString(MilkStatus.checkedOut.name),
      Variable.withString(MilkStatus.discarded.name),
      Variable.withString(MilkStatus.discarded.name),
    ]);
    return variables;
  }

  Future<MilkRecordRow> _findRowRequired(String id) async {
    final row = await (database.select(
      database.milkRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) throw const MilkRepositoryFailure('record_not_found');
    return row;
  }

  Future<domain.MilkRecord> _findRequired(String id) async =>
      _mapRecord(await _findRowRequired(id));

  Future<domain.MilkRecord> _mapRecord(MilkRecordRow row) async {
    final links = await (database.select(
      database.milkFoodTags,
    )..where((table) => table.milkId.equals(row.id))).get();
    return domain.MilkRecord(
      id: row.id,
      storedAtUtc: row.storedAtUtc.toUtc(),
      timezoneOffsetMinutes: row.timezoneOffsetMinutes,
      amountMl: row.amountMl,
      storageMode: row.storageMode,
      foodTagIds: links.map((link) => link.foodTagId).toList(growable: false),
      foodNotes: row.foodNotes,
      status: row.status,
      bestUseAtUtc: row.bestUseAtUtc?.toUtc(),
      expiresAtUtc: row.expiresAtUtc.toUtc(),
      thawStartedAtUtc: row.thawStartedAtUtc?.toUtc(),
      checkedOutAtUtc: row.checkedOutAtUtc?.toUtc(),
      discardedAtUtc: row.discardedAtUtc?.toUtc(),
      printStatus: row.printStatus,
      lastPrintedAtUtc: row.lastPrintedAtUtc?.toUtc(),
      expiryRuleVersion: row.expiryRuleVersion,
      createdAtUtc: row.createdAtUtc.toUtc(),
      updatedAtUtc: row.updatedAtUtc.toUtc(),
    );
  }

  domain.MilkStatusEvent _mapEvent(MilkStatusEventRow row) {
    final decoded = jsonDecode(row.metadataJson);
    return domain.MilkStatusEvent(
      id: row.id,
      milkId: row.milkId,
      type: row.type,
      occurredAtUtc: row.occurredAtUtc.toUtc(),
      fromStatus: row.fromStatus,
      toStatus: row.toStatus,
      metadata: decoded is Map<String, Object?>
          ? decoded
          : Map<String, Object?>.from(decoded as Map),
    );
  }

  domain.FoodTag _mapFoodTag(FoodTagRow row) => domain.FoodTag(
    id: row.id,
    name: row.name,
    createdAtUtc: row.createdAtUtc.toUtc(),
    updatedAtUtc: row.updatedAtUtc.toUtc(),
    lastUsedAtUtc: row.lastUsedAtUtc?.toUtc(),
    useCount: row.useCount,
    isActive: row.isActive,
  );

  Future<void> _replaceFoodTags(
    String milkId,
    Iterable<String> tagIds,
    DateTime usedAtUtc,
  ) async {
    final previousLinks = await (database.select(
      database.milkFoodTags,
    )..where((table) => table.milkId.equals(milkId))).get();
    final previousTagIds = previousLinks.map((link) => link.foodTagId).toSet();
    final uniqueTagIds = tagIds.toSet();

    for (final tagId in uniqueTagIds) {
      final tag = await (database.select(
        database.foodTags,
      )..where((table) => table.id.equals(tagId))).getSingleOrNull();
      if (tag == null) {
        throw const MilkRepositoryFailure('food_tag_not_found');
      }
    }

    await (database.delete(
      database.milkFoodTags,
    )..where((table) => table.milkId.equals(milkId))).go();
    for (final tagId in uniqueTagIds) {
      await database
          .into(database.milkFoodTags)
          .insert(
            MilkFoodTagsCompanion.insert(milkId: milkId, foodTagId: tagId),
          );
      if (!previousTagIds.contains(tagId)) {
        final tag = await (database.select(
          database.foodTags,
        )..where((table) => table.id.equals(tagId))).getSingle();
        await (database.update(
          database.foodTags,
        )..where((table) => table.id.equals(tagId))).write(
          FoodTagsCompanion(
            lastUsedAtUtc: Value(usedAtUtc),
            useCount: Value(tag.useCount + 1),
            updatedAtUtc: Value(usedAtUtc),
          ),
        );
      }
    }
  }

  Future<bool> _foodTagIdExists(String id) async =>
      await (database.select(
        database.foodTags,
      )..where((table) => table.id.equals(id))).getSingleOrNull() !=
      null;

  Future<void> _insertEvent({
    required String milkId,
    required MilkStatusEventType type,
    required DateTime occurredAtUtc,
    required MilkStatus? from,
    required MilkStatus to,
    Map<String, Object?> metadata = const {},
  }) async {
    var suffix = 0;
    String id;
    do {
      id =
          '${milkId}_${occurredAtUtc.microsecondsSinceEpoch}_${type.index}_$suffix';
      suffix++;
    } while (await _eventIdExists(id));

    await database
        .into(database.milkStatusEvents)
        .insert(
          MilkStatusEventsCompanion.insert(
            id: id,
            milkId: milkId,
            type: type,
            occurredAtUtc: occurredAtUtc,
            fromStatus: Value(from),
            toStatus: to,
            metadataJson: Value(jsonEncode(metadata)),
          ),
        );
  }

  Future<bool> _eventIdExists(String id) async =>
      await (database.select(
        database.milkStatusEvents,
      )..where((table) => table.id.equals(id))).getSingleOrNull() !=
      null;

  Future<MilkStatus?> _checkoutOrigin(String milkId) async {
    final event =
        await (database.select(database.milkStatusEvents)
              ..where(
                (table) =>
                    table.milkId.equals(milkId) &
                    table.type.equalsValue(MilkStatusEventType.checkedOut),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.occurredAtUtc)])
              ..limit(1))
            .getSingleOrNull();
    if (event == null) return null;
    final metadata = jsonDecode(event.metadataJson);
    if (metadata is! Map) return null;
    final name = metadata['restoreStatus']?.toString();
    return MilkStatus.values.where((status) => status.name == name).firstOrNull;
  }

  MilkRecordsCompanion _transitionUpdate(
    MilkRecordRow current,
    MilkTransition transition,
  ) {
    final at = transition.occurredAtUtc;
    return switch (transition.action) {
      MilkAction.startThawing => MilkRecordsCompanion(
        status: Value(transition.to),
        bestUseAtUtc: const Value(null),
        thawStartedAtUtc: Value(at),
        expiresAtUtc: Value(
          expiryPolicy.forThawing(thawStartedAtUtc: at).expiresAtUtc,
        ),
        updatedAtUtc: Value(at),
      ),
      MilkAction.checkOut => MilkRecordsCompanion(
        status: Value(transition.to),
        checkedOutAtUtc: Value(at),
        updatedAtUtc: Value(at),
      ),
      MilkAction.markExpired => MilkRecordsCompanion(
        status: Value(transition.to),
        updatedAtUtc: Value(at),
      ),
      MilkAction.discard => MilkRecordsCompanion(
        status: Value(transition.to),
        discardedAtUtc: Value(at),
        updatedAtUtc: Value(at),
      ),
      MilkAction.undoCheckOut => MilkRecordsCompanion(
        status: Value(transition.to),
        checkedOutAtUtc: const Value(null),
        updatedAtUtc: Value(at),
      ),
    };
  }

  void _requireUtc(DateTime value) {
    if (!value.isUtc) throw const MilkRepositoryFailure('utc_required');
  }
}
