import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';

class DailyMilkVolume {
  const DailyMilkVolume({
    required this.date,
    required this.intakeMl,
    required this.checkoutMl,
  });

  /// Local calendar date at midnight.
  final DateTime date;
  final int intakeMl;
  final int checkoutMl;
}

class WeeklyMilkFlow {
  const WeeklyMilkFlow(this.days);

  final List<DailyMilkVolume> days;

  int get intakeMl => days.fold(0, (sum, day) => sum + day.intakeMl);

  int get checkoutMl => days.fold(0, (sum, day) => sum + day.checkoutMl);
}

/// Rolls intake and checkout volume into the last 7 local calendar days.
///
/// Intake uses each record's storage timezone. Checkout uses
/// [checkoutOffsetMinutes], the same offset used to display checkout time.
/// Only bags still checked out count as outbound volume.
class WeeklyMilkFlowCalculator {
  const WeeklyMilkFlowCalculator();

  static const dayCount = 7;

  WeeklyMilkFlow calculate(
    Iterable<MilkRecord> records, {
    required DateTime today,
    required int checkoutOffsetMinutes,
  }) {
    final end = DateTime(today.year, today.month, today.day);
    final start = DateTime(end.year, end.month, end.day - (dayCount - 1));
    final intake = <DateTime, int>{};
    final checkout = <DateTime, int>{};

    for (final record in records) {
      final storedDay = _calendarDay(
        record.storedAtUtc,
        record.timezoneOffsetMinutes,
      );
      if (_contains(storedDay, start, end)) {
        intake[storedDay] = (intake[storedDay] ?? 0) + record.amountMl;
      }

      final checkedOutAt = record.checkedOutAtUtc;
      if (record.status != MilkStatus.checkedOut || checkedOutAt == null) {
        continue;
      }
      final checkoutDay = _calendarDay(checkedOutAt, checkoutOffsetMinutes);
      if (_contains(checkoutDay, start, end)) {
        checkout[checkoutDay] = (checkout[checkoutDay] ?? 0) + record.amountMl;
      }
    }

    return WeeklyMilkFlow([
      for (var offset = 0; offset < dayCount; offset++)
        DailyMilkVolume(
          date: DateTime(start.year, start.month, start.day + offset),
          intakeMl:
              intake[DateTime(start.year, start.month, start.day + offset)] ??
              0,
          checkoutMl:
              checkout[DateTime(start.year, start.month, start.day + offset)] ??
              0,
        ),
    ]);
  }

  DateTime _calendarDay(DateTime utc, int offsetMinutes) {
    final local = utc.toUtc().add(Duration(minutes: offsetMinutes));
    return DateTime(local.year, local.month, local.day);
  }

  bool _contains(DateTime day, DateTime start, DateTime end) {
    return !day.isBefore(start) && !day.isAfter(end);
  }
}
