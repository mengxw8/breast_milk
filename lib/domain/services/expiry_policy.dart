import 'dart:math' as math;

import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';

class ExpiryPolicy {
  const ExpiryPolicy({
    this.refrigeratedDays = 4,
    this.frozenMonths = 12,
    this.frozenBestUseMonths = 6,
  }) : assert(refrigeratedDays > 0),
       assert(frozenMonths > 0),
       assert(frozenBestUseMonths > 0 && frozenBestUseMonths <= frozenMonths);

  final int refrigeratedDays;
  final int frozenMonths;
  final int frozenBestUseMonths;

  factory ExpiryPolicy.fromSettings(
    Map<String, dynamic> values, {
    ExpiryPolicy fallback = const ExpiryPolicy(),
  }) {
    int read(String key, int fallback, int max) {
      final value = values[key];
      return value is int && value > 0 && value <= max ? value : fallback;
    }

    final frozen = read('expiry.frozenMonths', fallback.frozenMonths, 120);
    return ExpiryPolicy(
      refrigeratedDays: read(
        'expiry.refrigeratedDays',
        fallback.refrigeratedDays,
        365,
      ),
      frozenMonths: frozen,
      frozenBestUseMonths: math.min(
        read('expiry.frozenBestUseMonths', fallback.frozenBestUseMonths, 120),
        frozen,
      ),
    );
  }

  static const ruleVersion = 'cdc-2025-v1';

  String get _storageRuleVersion =>
      refrigeratedDays == 4 && frozenMonths == 12 && frozenBestUseMonths == 6
      ? ruleVersion
      : 'custom-v1:$refrigeratedDays:$frozenMonths:$frozenBestUseMonths';

  ExpiryWindow forStorage({
    required MilkStorageMode mode,
    required DateTime storedAtUtc,
    required int timezoneOffsetMinutes,
  }) {
    _requireUtc(storedAtUtc);
    return switch (mode) {
      MilkStorageMode.frozen => ExpiryWindow(
        bestUseAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          frozenBestUseMonths,
        ),
        expiresAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          frozenMonths,
        ),
        bestUseReminderAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          frozenBestUseMonths - 1,
        ),
        finalExpiryReminderAtUtc: _addCalendarMonths(
          storedAtUtc,
          timezoneOffsetMinutes,
          frozenMonths - 1,
        ),
        ruleVersion: _storageRuleVersion,
      ),
      MilkStorageMode.refrigerated => ExpiryWindow(
        expiresAtUtc: storedAtUtc.add(Duration(days: refrigeratedDays)),
        ruleVersion: _storageRuleVersion,
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

  ExpiryRisk assessRecord(MilkRecord record, DateTime nowUtc) {
    final parts = record.expiryRuleVersion.split(':');
    final policy = parts.length == 4 && parts.first == 'custom-v1'
        ? ExpiryPolicy.fromSettings({
            'expiry.refrigeratedDays': int.tryParse(parts[1]),
            'expiry.frozenMonths': int.tryParse(parts[2]),
            'expiry.frozenBestUseMonths': int.tryParse(parts[3]),
          })
        : const ExpiryPolicy();
    final storage = policy.forStorage(
      mode: record.storageMode,
      storedAtUtc: record.storedAtUtc,
      timezoneOffsetMinutes: record.timezoneOffsetMinutes,
    );
    return assess(
      status: record.status,
      nowUtc: nowUtc,
      window: ExpiryWindow(
        expiresAtUtc: record.expiresAtUtc,
        bestUseAtUtc: record.bestUseAtUtc,
        bestUseReminderAtUtc: storage.bestUseReminderAtUtc,
        finalExpiryReminderAtUtc: storage.finalExpiryReminderAtUtc,
        ruleVersion: record.expiryRuleVersion,
      ),
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
