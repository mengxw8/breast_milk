import 'dart:math' as math;

import 'package:breast_milk/domain/models/milk_enums.dart';

class ExpiryPolicy {
  const ExpiryPolicy();

  static const ruleVersion = 'cdc-2025-v1';

  ExpiryWindow forStorage({
    required MilkStorageMode mode,
    required DateTime storedAtUtc,
    required int timezoneOffsetMinutes,
  }) {
    _requireUtc(storedAtUtc);
    return switch (mode) {
      MilkStorageMode.frozen => ExpiryWindow(
        bestUseAtUtc: _addCalendarMonths(storedAtUtc, timezoneOffsetMinutes, 6),
        expiresAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          12,
        ),
        bestUseReminderAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          5,
        ),
        finalExpiryReminderAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          11,
        ),
        ruleVersion: ruleVersion,
      ),
      MilkStorageMode.refrigerated => ExpiryWindow(
        expiresAtUtc: storedAtUtc.add(const Duration(hours: 96)),
        ruleVersion: ruleVersion,
      ),
    };
  }

  ExpiryWindow forThawing({required DateTime thawStartedAtUtc}) {
    _requireUtc(thawStartedAtUtc);
    return ExpiryWindow(
      expiresAtUtc: thawStartedAtUtc.add(const Duration(hours: 24)),
      ruleVersion: ruleVersion,
    );
  }

  ExpiryRisk assess({
    required MilkStatus status,
    required ExpiryWindow window,
    required DateTime nowUtc,
  }) {
    _requireUtc(nowUtc);
    if (status == MilkStatus.checkedOut || status == MilkStatus.discarded) {
      return ExpiryRisk.none;
    }
    if (status == MilkStatus.expired) return ExpiryRisk.expired;
    if (!nowUtc.isBefore(window.expiresAtUtc)) return ExpiryRisk.expired;
    if (status == MilkStatus.thawing) return ExpiryRisk.thawing;
    if (status == MilkStatus.refrigeratedInStock) {
      return ExpiryRisk.refrigerated;
    }
    if (status != MilkStatus.frozenInStock) return ExpiryRisk.none;

    final finalReminder = window.finalExpiryReminderAtUtc;
    if (finalReminder != null && !nowUtc.isBefore(finalReminder)) {
      return ExpiryRisk.finalExpirySoon;
    }
    final bestUse = window.bestUseAtUtc;
    if (bestUse != null && !nowUtc.isBefore(bestUse)) {
      return ExpiryRisk.bestUsePassed;
    }
    final bestReminder = window.bestUseReminderAtUtc;
    if (bestReminder != null && !nowUtc.isBefore(bestReminder)) {
      return ExpiryRisk.bestUseSoon;
    }
    return ExpiryRisk.none;
  }

  DateTime _addCalendarMonths(
    DateTime instantUtc,
    int offsetMinutes,
    int months,
  ) {
    if (offsetMinutes < -14 * 60 || offsetMinutes > 14 * 60) {
      throw const ExpiryPolicyFailure('invalid_timezone_offset');
    }
    final wallTime = instantUtc.add(Duration(minutes: offsetMinutes));
    final monthIndex = wallTime.year * 12 + wallTime.month - 1 + months;
    final targetYear = monthIndex ~/ 12;
    final targetMonth = monthIndex % 12 + 1;
    final lastDay = DateTime.utc(targetYear, targetMonth + 1, 0).day;
    final targetDay = math.min(wallTime.day, lastDay);
    final targetWallTime = DateTime.utc(
      targetYear,
      targetMonth,
      targetDay,
      wallTime.hour,
      wallTime.minute,
      wallTime.second,
      wallTime.millisecond,
      wallTime.microsecond,
    );
    return targetWallTime.subtract(Duration(minutes: offsetMinutes));
  }

  void _requireUtc(DateTime value) {
    if (!value.isUtc) {
      throw const ExpiryPolicyFailure('utc_required');
    }
  }
}

class ExpiryWindow {
  const ExpiryWindow({
    required this.expiresAtUtc,
    required this.ruleVersion,
    this.bestUseAtUtc,
    this.bestUseReminderAtUtc,
    this.finalExpiryReminderAtUtc,
  });

  final DateTime? bestUseAtUtc;
  final DateTime expiresAtUtc;
  final DateTime? bestUseReminderAtUtc;
  final DateTime? finalExpiryReminderAtUtc;
  final String ruleVersion;
}

class ExpiryPolicyFailure implements Exception {
  const ExpiryPolicyFailure(this.code);

  final String code;
}
