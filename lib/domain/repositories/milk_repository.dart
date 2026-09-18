import 'package:breast_milk/domain/models/food_tag.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/models/milk_status_event.dart';
import 'package:breast_milk/domain/services/inventory_calculator.dart';

abstract interface class MilkRepository {
  Future<MilkRecord> create(CreateMilkRecordCommand command);

  Future<MilkRecord?> findById(String id);

  Future<List<MilkRecord>> list(MilkRecordFilter filter);

  Future<MilkRecord> update(UpdateMilkRecordCommand command);

  Future<MilkRecord> transition(TransitionMilkRecordCommand command);

  Future<void> deleteById(String id);

  Future<void> updatePrintStatus({
    required String id,
    required PrintStatus status,
    required DateTime updatedAtUtc,
  });

  Future<List<MilkRecord>> pendingPrints();

  Future<List<MilkStatusEvent>> eventsFor(String milkId);

  Future<MilkRecord?> earliestUsable(DateTime nowUtc);

  Future<InventorySummary> inventorySummary(DateTime nowUtc);

  Future<FoodTag> saveFoodTag({required String name, required DateTime atUtc});

  /// Soft-delete: hide from common list, keep record associations.
  Future<void> deleteFoodTag(String id);

  /// Active common tags for intake / settings management.
  Future<List<FoodTag>> listFoodTags();

  /// Resolve tags by id, including soft-deleted ones (for record display).
  Future<List<FoodTag>> foodTagsByIds(Iterable<String> ids);
}

class CreateMilkRecordCommand {
  const CreateMilkRecordCommand({
    required this.storedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.amountMl,
    required this.storageMode,
    required this.createdAtUtc,
    this.foodTagIds = const [],
    this.foodNotes = '',
  });

  final DateTime storedAtUtc;
  final int timezoneOffsetMinutes;
  final int amountMl;
  final MilkStorageMode storageMode;
  final List<String> foodTagIds;
  final String foodNotes;
  final DateTime createdAtUtc;
}

class UpdateMilkRecordCommand {
  const UpdateMilkRecordCommand({
    required this.id,
    required this.storedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.amountMl,
    required this.storageMode,
    required this.updatedAtUtc,
    this.foodTagIds = const [],
    this.foodNotes = '',
  });

  final String id;
  final DateTime storedAtUtc;
  final int timezoneOffsetMinutes;
  final int amountMl;
  final MilkStorageMode storageMode;
  final List<String> foodTagIds;
  final String foodNotes;
  final DateTime updatedAtUtc;
}

class TransitionMilkRecordCommand {
  const TransitionMilkRecordCommand({
    required this.id,
    required this.action,
    required this.occurredAtUtc,
  });

  final String id;
  final MilkAction action;
  final DateTime occurredAtUtc;
}

class MilkRecordFilter {
  const MilkRecordFilter({
    this.statuses = const {},
    this.storageModes = const {},
    this.foodTagIds = const {},
    this.storedFromUtc,
    this.storedUntilUtc,
    this.searchText = '',
  });

  final Set<MilkStatus> statuses;
  final Set<MilkStorageMode> storageModes;
  final Set<String> foodTagIds;
  final DateTime? storedFromUtc;
  final DateTime? storedUntilUtc;
  final String searchText;
}

class MilkRepositoryFailure implements Exception {
  const MilkRepositoryFailure(this.code);

  final String code;

  @override
  String toString() => 'MilkRepositoryFailure($code)';
}
