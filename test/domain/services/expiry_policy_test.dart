import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/services/expiry_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = ExpiryPolicy();

  group('冷冻期限', () {
    test('按当地墙上时间增加6和12个自然月并保留时区偏移', () {
      final storedAtUtc = DateTime.utc(2026, 1, 14, 22, 30);

      final window = policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: storedAtUtc,
        timezoneOffsetMinutes: 8 * 60,
      );

      expect(window.bestUseAtUtc, DateTime.utc(2026, 7, 14, 22, 30));
      expect(window.expiresAtUtc, DateTime.utc(2027, 1, 14, 22, 30));
      expect(window.ruleVersion, ExpiryPolicy.ruleVersion);
    });

    test('月末遇到较短目标月时截断到目标月最后一天', () {
      final window = policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: DateTime.utc(2024, 8, 31, 4),
        timezoneOffsetMinutes: 0,
      );

      expect(window.bestUseAtUtc, DateTime.utc(2025, 2, 28, 4));
      expect(window.expiresAtUtc, DateTime.utc(2025, 8, 31, 4));
    });

    test('目标二月处于闰年时保留2月29日', () {
      final window = policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: DateTime.utc(2023, 8, 31, 4),
        timezoneOffsetMinutes: 0,
      );

      expect(window.bestUseAtUtc, DateTime.utc(2024, 2, 29, 4));
    });

    test('风险节点在边界时立即生效', () {
      final window = policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: DateTime.utc(2026),
        timezoneOffsetMinutes: 0,
      );

      expect(
        policy.assess(
          status: MilkStatus.frozenInStock,
          window: window,
          nowUtc: DateTime.utc(2026, 6),
        ),
        ExpiryRisk.bestUseSoon,
      );
      expect(
        policy.assess(
          status: MilkStatus.frozenInStock,
          window: window,
          nowUtc: DateTime.utc(2026, 7),
        ),
        ExpiryRisk.bestUsePassed,
      );
      expect(
        policy.assess(
          status: MilkStatus.frozenInStock,
          window: window,
          nowUtc: DateTime.utc(2026, 12),
        ),
        ExpiryRisk.finalExpirySoon,
      );
      expect(
        policy.assess(
          status: MilkStatus.frozenInStock,
          window: window,
          nowUtc: DateTime.utc(2027),
        ),
        ExpiryRisk.expired,
      );
    });
  });

  test('冷藏期限为精确96小时', () {
    final storedAtUtc = DateTime.utc(2026, 9, 10, 3, 57);
    final window = policy.forStorage(
      mode: MilkStorageMode.refrigerated,
      storedAtUtc: storedAtUtc,
      timezoneOffsetMinutes: 8 * 60,
    );

    expect(window.bestUseAtUtc, isNull);
    expect(window.expiresAtUtc, DateTime.utc(2026, 9, 14, 3, 57));
    expect(
      policy.assess(
        status: MilkStatus.refrigeratedInStock,
        window: window,
        nowUtc: storedAtUtc,
      ),
      ExpiryRisk.refrigerated,
    );
  });

  test('解冻期限为开始解冻后精确24小时', () {
    final startedAt = DateTime.utc(2026, 9, 10, 8);
    final window = policy.forThawing(thawStartedAtUtc: startedAt);

    expect(window.expiresAtUtc, DateTime.utc(2026, 9, 11, 8));
    expect(
      policy.assess(
        status: MilkStatus.thawing,
        window: window,
        nowUtc: DateTime.utc(2026, 9, 11, 7, 59, 59),
      ),
      ExpiryRisk.thawing,
    );
    expect(
      policy.assess(
        status: MilkStatus.thawing,
        window: window,
        nowUtc: DateTime.utc(2026, 9, 11, 8),
      ),
      ExpiryRisk.expired,
    );
  });

  test('已出库和已丢弃记录不再产生期限风险', () {
    final window = policy.forStorage(
      mode: MilkStorageMode.frozen,
      storedAtUtc: DateTime.utc(2025),
      timezoneOffsetMinutes: 0,
    );

    for (final status in [MilkStatus.checkedOut, MilkStatus.discarded]) {
      expect(
        policy.assess(
          status: status,
          window: window,
          nowUtc: DateTime.utc(2027),
        ),
        ExpiryRisk.none,
      );
    }
  });

  test('拒绝超出实际时区范围的偏移', () {
    expect(
      () => policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: DateTime.utc(2026),
        timezoneOffsetMinutes: 15 * 60,
      ),
      throwsA(isA<ExpiryPolicyFailure>()),
    );
  });

  test('拒绝没有明确UTC语义的时间', () {
    expect(
      () => policy.forStorage(
        mode: MilkStorageMode.frozen,
        storedAtUtc: DateTime(2026),
        timezoneOffsetMinutes: 0,
      ),
      throwsA(isA<ExpiryPolicyFailure>()),
    );
  });
}
