import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/services/weekly_milk_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = WeeklyMilkFlowCalculator();
  final today = DateTime(2026, 9, 23, 15, 30);

  test('按入库当地日期和出库当天汇总最近 7 天', () {
    final flow = calculator.calculate(
      [
        _record(
          id: 'in-today',
          amountMl: 120,
          storedAtUtc: DateTime.utc(2026, 9, 22, 16),
          offsetMinutes: 8 * 60,
        ),
        _record(
          id: 'in-start',
          amountMl: 80,
          storedAtUtc: DateTime.utc(2026, 9, 17, 1),
          offsetMinutes: 8 * 60,
        ),
        _record(
          id: 'too-old',
          amountMl: 50,
          storedAtUtc: DateTime.utc(2026, 9, 16, 1),
          offsetMinutes: 8 * 60,
        ),
        _record(
          id: 'out-today',
          amountMl: 40,
          storedAtUtc: DateTime.utc(2026, 9, 20, 2),
          offsetMinutes: 0,
          status: MilkStatus.checkedOut,
          checkedOutAtUtc: DateTime.utc(2026, 9, 22, 18),
        ),
        _record(
          id: 'discarded',
          amountMl: 30,
          storedAtUtc: DateTime.utc(2026, 9, 21, 2),
          offsetMinutes: 0,
          status: MilkStatus.discarded,
          checkedOutAtUtc: DateTime.utc(2026, 9, 22, 18),
        ),
        _record(
          id: 'undone',
          amountMl: 25,
          storedAtUtc: DateTime.utc(2026, 9, 21, 3),
          offsetMinutes: 0,
        ),
      ],
      today: today,
      checkoutOffsetMinutes: 8 * 60,
    );

    expect(flow.days, hasLength(7));
    expect(flow.days.first.date, DateTime(2026, 9, 17));
    expect(flow.days.last.date, DateTime(2026, 9, 23));
    expect(flow.days.first.intakeMl, 80);
    expect(flow.days.first.checkoutMl, 0);
    expect(flow.days.last.intakeMl, 120);
    expect(flow.days.last.checkoutMl, 40);
    expect(flow.intakeMl, 295);
    expect(flow.checkoutMl, 40);
  });

  test('同一天多袋累加，空日期记为 0', () {
    final flow = calculator.calculate(
      [
        _record(
          id: 'a',
          amountMl: 100,
          storedAtUtc: DateTime.utc(2026, 9, 23, 1),
          offsetMinutes: 0,
        ),
        _record(
          id: 'b',
          amountMl: 60,
          storedAtUtc: DateTime.utc(2026, 9, 23, 8),
          offsetMinutes: 0,
          status: MilkStatus.checkedOut,
          checkedOutAtUtc: DateTime.utc(2026, 9, 23, 9),
        ),
        _record(
          id: 'c',
          amountMl: 40,
          storedAtUtc: DateTime.utc(2026, 9, 22, 8),
          offsetMinutes: 0,
          status: MilkStatus.checkedOut,
          checkedOutAtUtc: DateTime.utc(2026, 9, 23, 10),
        ),
      ],
      today: today,
      checkoutOffsetMinutes: 0,
    );

    expect(flow.days.last.intakeMl, 160);
    expect(flow.days.last.checkoutMl, 100);
    expect(flow.days[5].intakeMl, 40);
    expect(flow.days[5].checkoutMl, 0);
    expect(flow.days[4].intakeMl, 0);
    expect(flow.days[4].checkoutMl, 0);
  });
}

MilkRecord _record({
  required String id,
  required int amountMl,
  required DateTime storedAtUtc,
  required int offsetMinutes,
  MilkStatus status = MilkStatus.frozenInStock,
  DateTime? checkedOutAtUtc,
}) {
  return MilkRecord(
    id: id,
    storedAtUtc: storedAtUtc,
    timezoneOffsetMinutes: offsetMinutes,
    amountMl: amountMl,
    storageMode: MilkStorageMode.frozen,
    status: status,
    expiresAtUtc: storedAtUtc.add(const Duration(days: 30)),
    printStatus: PrintStatus.notPrinted,
    expiryRuleVersion: 'test',
    createdAtUtc: storedAtUtc,
    updatedAtUtc: storedAtUtc,
    checkedOutAtUtc: checkedOutAtUtc,
  );
}
