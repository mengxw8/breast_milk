import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/services/inventory_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = InventoryCalculator();
  final now = DateTime.utc(2026, 9, 10, 12);

  test('分别统计可用库存、实体库存和已处理口径', () {
    final summary = calculator.calculate([
      _record('01', 100, MilkStatus.frozenInStock, now, expiresInHours: 24),
      _record(
        '02',
        120,
        MilkStatus.refrigeratedInStock,
        now,
        expiresInHours: 24,
      ),
      _record('03', 80, MilkStatus.thawing, now, expiresInHours: 12),
      _record('04', 90, MilkStatus.expired, now, expiresInHours: -1),
      _record('05', 110, MilkStatus.checkedOut, now, expiresInHours: -10),
      _record('06', 70, MilkStatus.discarded, now, expiresInHours: -10),
    ], nowUtc: now);

    expect(summary.available.bagCount, 3);
    expect(summary.available.totalMl, 300);
    expect(summary.physical.bagCount, 4);
    expect(summary.physical.totalMl, 390);
    expect(summary.frozen.totalMl, 100);
    expect(summary.refrigerated.totalMl, 120);
    expect(summary.thawing.totalMl, 80);
    expect(summary.expired.totalMl, 90);
    expect(summary.checkedOut.totalMl, 110);
    expect(summary.discarded.totalMl, 70);
  });

  test('期限已过但状态尚未落库时动态归入过期实体库存', () {
    final summary = calculator.calculate([
      _record('01', 100, MilkStatus.frozenInStock, now, expiresInHours: -1),
    ], nowUtc: now);

    expect(summary.available.bagCount, 0);
    expect(summary.physical.bagCount, 1);
    expect(summary.expired.totalMl, 100);
  });

  test('已出库和已丢弃即使期限已过也保持各自统计', () {
    final summary = calculator.calculate([
      _record('01', 100, MilkStatus.checkedOut, now, expiresInHours: -1),
      _record('02', 120, MilkStatus.discarded, now, expiresInHours: -1),
    ], nowUtc: now);

    expect(summary.physical.bagCount, 0);
    expect(summary.expired.bagCount, 0);
    expect(summary.checkedOut.totalMl, 100);
    expect(summary.discarded.totalMl, 120);
  });
}

MilkRecord _record(
  String suffix,
  int amountMl,
  MilkStatus status,
  DateTime now, {
  required int expiresInHours,
}) {
  return MilkRecord(
    id: '20260910120000$suffix',
    storedAtUtc: now.subtract(const Duration(hours: 1)),
    timezoneOffsetMinutes: 8 * 60,
    amountMl: amountMl,
    storageMode: status == MilkStatus.refrigeratedInStock
        ? MilkStorageMode.refrigerated
        : MilkStorageMode.frozen,
    status: status,
    expiresAtUtc: now.add(Duration(hours: expiresInHours)),
    printStatus: PrintStatus.notPrinted,
    expiryRuleVersion: 'test',
    createdAtUtc: now,
    updatedAtUtc: now,
  );
}
