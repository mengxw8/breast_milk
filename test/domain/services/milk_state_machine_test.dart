import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/services/milk_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const machine = MilkStateMachine();
  final beforeExpiry = DateTime.utc(2026, 9, 10);
  final expiresAt = DateTime.utc(2026, 9, 11);

  final allowed = <(MilkStatus, MilkAction, MilkStatus)>[
    (MilkStatus.frozenInStock, MilkAction.startThawing, MilkStatus.thawing),
    (MilkStatus.frozenInStock, MilkAction.checkOut, MilkStatus.checkedOut),
    (
      MilkStatus.refrigeratedInStock,
      MilkAction.checkOut,
      MilkStatus.checkedOut,
    ),
    (MilkStatus.thawing, MilkAction.checkOut, MilkStatus.checkedOut),
    (MilkStatus.expired, MilkAction.discard, MilkStatus.discarded),
    (MilkStatus.checkedOut, MilkAction.discard, MilkStatus.discarded),
  ];

  for (final (from, action, to) in allowed) {
    test('允许 ${from.name} -> ${action.name} -> ${to.name}', () {
      final transition = machine.transition(
        currentStatus: from,
        action: action,
        atUtc: beforeExpiry,
        expiresAtUtc: expiresAt,
      );

      expect(transition.from, from);
      expect(transition.to, to);
      expect(transition.occurredAtUtc, beforeExpiry);
    });
  }

  for (final status in [
    MilkStatus.frozenInStock,
    MilkStatus.refrigeratedInStock,
    MilkStatus.thawing,
  ]) {
    test('允许到期的 ${status.name} 标记为过期', () {
      final transition = machine.transition(
        currentStatus: status,
        action: MilkAction.markExpired,
        atUtc: expiresAt,
        expiresAtUtc: expiresAt,
      );

      expect(transition.to, MilkStatus.expired);
      expect(transition.eventType, MilkStatusEventType.expired);
    });
  }

  for (final restoreStatus in [
    MilkStatus.frozenInStock,
    MilkStatus.refrigeratedInStock,
    MilkStatus.thawing,
  ]) {
    test('出库后可短时撤销到 ${restoreStatus.name}', () {
      final transition = machine.transition(
        currentStatus: MilkStatus.checkedOut,
        action: MilkAction.undoCheckOut,
        atUtc: beforeExpiry,
        expiresAtUtc: expiresAt,
        restoreStatus: restoreStatus,
      );

      expect(transition.to, restoreStatus);
      expect(transition.eventType, MilkStatusEventType.checkOutUndone);
    });
  }

  test('开始解冻后禁止返回冷冻状态', () {
    expect(
      () => machine.transition(
        currentStatus: MilkStatus.thawing,
        action: MilkAction.undoCheckOut,
        atUtc: beforeExpiry,
        expiresAtUtc: expiresAt,
        restoreStatus: MilkStatus.frozenInStock,
      ),
      throwsA(_transitionFailure('transition_not_allowed')),
    );
  });

  test('未到期记录不能提前标记过期', () {
    expect(
      () => machine.transition(
        currentStatus: MilkStatus.frozenInStock,
        action: MilkAction.markExpired,
        atUtc: beforeExpiry,
        expiresAtUtc: expiresAt,
      ),
      throwsA(_transitionFailure('transition_not_allowed')),
    );
  });

  test('已到期记录禁止出库或开始解冻', () {
    for (final action in [MilkAction.checkOut, MilkAction.startThawing]) {
      expect(
        () => machine.transition(
          currentStatus: MilkStatus.frozenInStock,
          action: action,
          atUtc: expiresAt,
          expiresAtUtc: expiresAt,
        ),
        throwsA(_transitionFailure('milk_expired')),
      );
    }
  });

  test('撤销出库时不能恢复为终态', () {
    for (final restoreStatus in [
      null,
      MilkStatus.checkedOut,
      MilkStatus.expired,
      MilkStatus.discarded,
    ]) {
      expect(
        () => machine.transition(
          currentStatus: MilkStatus.checkedOut,
          action: MilkAction.undoCheckOut,
          atUtc: beforeExpiry,
          expiresAtUtc: expiresAt,
          restoreStatus: restoreStatus,
        ),
        throwsA(_transitionFailure('transition_not_allowed')),
      );
    }
  });

  test('超过原期限后不能撤销出库', () {
    expect(
      () => machine.transition(
        currentStatus: MilkStatus.checkedOut,
        action: MilkAction.undoCheckOut,
        atUtc: expiresAt,
        expiresAtUtc: expiresAt,
        restoreStatus: MilkStatus.frozenInStock,
      ),
      throwsA(_transitionFailure('milk_expired')),
    );
  });

  test('未到期时除明确列出的转换外均禁止', () {
    const allowedPairs = {
      'frozenInStock:startThawing',
      'frozenInStock:checkOut',
      'refrigeratedInStock:checkOut',
      'thawing:checkOut',
      'expired:discard',
      'checkedOut:undoCheckOut',
    };

    for (final status in MilkStatus.values) {
      for (final action in MilkAction.values) {
        final key = '${status.name}:${action.name}';
        if (allowedPairs.contains(key)) continue;
        expect(
          () => machine.transition(
            currentStatus: status,
            action: action,
            atUtc: beforeExpiry,
            expiresAtUtc: expiresAt,
            restoreStatus: MilkStatus.frozenInStock,
          ),
          throwsA(_transitionFailure('transition_not_allowed')),
          reason: key,
        );
      }
    }
  });
}

Matcher _transitionFailure(String code) => isA<MilkTransitionFailure>().having(
  (failure) => failure.code,
  'code',
  code,
);
