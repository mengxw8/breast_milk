import 'package:breast_milk/domain/models/milk_enums.dart';

class MilkRecord {
  MilkRecord({
    required this.id,
    required this.storedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.amountMl,
    required this.storageMode,
    required this.status,
    required this.expiresAtUtc,
    required this.printStatus,
    required this.expiryRuleVersion,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.bestUseAtUtc,
    this.foodTagIds = const [],
    this.foodNotes = '',
    this.thawStartedAtUtc,
    this.checkedOutAtUtc,
    this.discardedAtUtc,
    this.lastPrintedAtUtc,
  }) : assert(amountMl > 0),
       assert(storedAtUtc.isUtc),
       assert(expiresAtUtc.isUtc),
       assert(bestUseAtUtc == null || bestUseAtUtc.isUtc),
       assert(thawStartedAtUtc == null || thawStartedAtUtc.isUtc),
       assert(checkedOutAtUtc == null || checkedOutAtUtc.isUtc),
       assert(discardedAtUtc == null || discardedAtUtc.isUtc),
       assert(lastPrintedAtUtc == null || lastPrintedAtUtc.isUtc),
       assert(createdAtUtc.isUtc),
       assert(updatedAtUtc.isUtc);

  final String id;
  final DateTime storedAtUtc;
  final int timezoneOffsetMinutes;
  final int amountMl;
  final MilkStorageMode storageMode;
  final List<String> foodTagIds;
  final String foodNotes;
  final MilkStatus status;
  final DateTime? bestUseAtUtc;
  final DateTime expiresAtUtc;
  final DateTime? thawStartedAtUtc;
  final DateTime? checkedOutAtUtc;
  final DateTime? discardedAtUtc;
  final PrintStatus printStatus;
  final DateTime? lastPrintedAtUtc;
  final String expiryRuleVersion;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  bool isExpiredAt(DateTime now) =>
      !now.toUtc().isBefore(expiresAtUtc) &&
      status != MilkStatus.checkedOut &&
      status != MilkStatus.discarded;
}
