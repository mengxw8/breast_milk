import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:drift/drift.dart';

@DataClassName('MilkRecordRow')
class MilkRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get storedAtUtc => dateTime()();
  IntColumn get timezoneOffsetMinutes => integer()();
  IntColumn get amountMl =>
      integer().check(const CustomExpression<bool>('amount_ml > 0'))();
  TextColumn get storageMode => textEnum<MilkStorageMode>()();
  TextColumn get foodNotes => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<MilkStatus>()();
  DateTimeColumn get bestUseAtUtc => dateTime().nullable()();
  DateTimeColumn get expiresAtUtc => dateTime()();
  DateTimeColumn get thawStartedAtUtc => dateTime().nullable()();
  DateTimeColumn get checkedOutAtUtc => dateTime().nullable()();
  DateTimeColumn get discardedAtUtc => dateTime().nullable()();
  TextColumn get printStatus => textEnum<PrintStatus>()();
  DateTimeColumn get lastPrintedAtUtc => dateTime().nullable()();
  TextColumn get expiryRuleVersion => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MilkStatusEventRow')
class MilkStatusEvents extends Table {
  TextColumn get id => text()();
  TextColumn get milkId =>
      text().references(MilkRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<MilkStatusEventType>()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  TextColumn get fromStatus => textEnum<MilkStatus>().nullable()();
  TextColumn get toStatus => textEnum<MilkStatus>()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FoodTagRow')
class FoodTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get lastUsedAtUtc => dateTime().nullable()();
  IntColumn get useCount => integer()
      .withDefault(const Constant(0))
      .check(const CustomExpression<bool>('use_count >= 0'))();
  /// Soft-delete: hidden from common lists, kept for historical record links.
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MilkFoodTagRow')
class MilkFoodTags extends Table {
  TextColumn get milkId =>
      text().references(MilkRecords, #id, onDelete: KeyAction.cascade)();
  TextColumn get foodTagId =>
      text().references(FoodTags, #id, onDelete: KeyAction.restrict)();

  @override
  Set<Column<Object>> get primaryKey => {milkId, foodTagId};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
