import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';

class InventoryCalculator {
  const InventoryCalculator();

  InventorySummary calculate(
    Iterable<MilkRecord> records, {
    required DateTime nowUtc,
  }) {
    if (!nowUtc.isUtc) {
      throw const InventoryCalculationFailure('utc_required');
    }

    var available = const InventoryMetric();
    var physical = const InventoryMetric();
    var frozen = const InventoryMetric();
    var refrigerated = const InventoryMetric();
    var thawing = const InventoryMetric();
    var expired = const InventoryMetric();
    var checkedOut = const InventoryMetric();
    var discarded = const InventoryMetric();

    for (final record in records) {
      final dynamicallyExpired = record.isExpiredAt(nowUtc);
      final effectiveStatus = dynamicallyExpired
          ? MilkStatus.expired
          : record.status;

      switch (effectiveStatus) {
        case MilkStatus.frozenInStock:
          available = available.add(record.amountMl);
          physical = physical.add(record.amountMl);
          frozen = frozen.add(record.amountMl);
        case MilkStatus.refrigeratedInStock:
          available = available.add(record.amountMl);
          physical = physical.add(record.amountMl);
          refrigerated = refrigerated.add(record.amountMl);
        case MilkStatus.thawing:
          available = available.add(record.amountMl);
          physical = physical.add(record.amountMl);
          thawing = thawing.add(record.amountMl);
        case MilkStatus.expired:
          physical = physical.add(record.amountMl);
          expired = expired.add(record.amountMl);
        case MilkStatus.checkedOut:
          checkedOut = checkedOut.add(record.amountMl);
        case MilkStatus.discarded:
          discarded = discarded.add(record.amountMl);
      }
    }

    return InventorySummary(
      available: available,
      physical: physical,
      frozen: frozen,
      refrigerated: refrigerated,
      thawing: thawing,
      expired: expired,
      checkedOut: checkedOut,
      discarded: discarded,
    );
  }
}

class InventorySummary {
  const InventorySummary({
    required this.available,
    required this.physical,
    required this.frozen,
    required this.refrigerated,
    required this.thawing,
    required this.expired,
    required this.checkedOut,
    required this.discarded,
  });

  final InventoryMetric available;
  final InventoryMetric physical;
  final InventoryMetric frozen;
  final InventoryMetric refrigerated;
  final InventoryMetric thawing;
  final InventoryMetric expired;
  final InventoryMetric checkedOut;
  final InventoryMetric discarded;
}

class InventoryMetric {
  const InventoryMetric({this.bagCount = 0, this.totalMl = 0});

  final int bagCount;
  final int totalMl;

  InventoryMetric add(int amountMl) =>
      InventoryMetric(bagCount: bagCount + 1, totalMl: totalMl + amountMl);
}

class InventoryCalculationFailure implements Exception {
  const InventoryCalculationFailure(this.code);

  final String code;
}
