import 'package:breast_milk/domain/models/milk_enums.dart';

class MilkStateMachine {
  const MilkStateMachine();

  MilkTransition transition({
    required MilkStatus currentStatus,
    required MilkAction action,
    required DateTime atUtc,
    required DateTime expiresAtUtc,
    MilkStatus? restoreStatus,
  }) {
    if (!atUtc.isUtc || !expiresAtUtc.isUtc) {
      throw const MilkTransitionFailure('utc_required');
    }

    final isActive = _activeStatuses.contains(currentStatus);
    final hasExpired = !atUtc.isBefore(expiresAtUtc);
    if (hasExpired && action == MilkAction.undoCheckOut) {
      throw const MilkTransitionFailure('milk_expired');
    }
    if (hasExpired && isActive && action != MilkAction.markExpired) {
      throw const MilkTransitionFailure('milk_expired');
    }

    final target = switch ((currentStatus, action)) {
      (MilkStatus.frozenInStock, MilkAction.startThawing) => MilkStatus.thawing,
      (
        MilkStatus.frozenInStock ||
            MilkStatus.refrigeratedInStock ||
            MilkStatus.thawing,
        MilkAction.checkOut,
      ) =>
        MilkStatus.checkedOut,
      (
        MilkStatus.frozenInStock ||
            MilkStatus.refrigeratedInStock ||
            MilkStatus.thawing,
        MilkAction.markExpired,
      )
          when hasExpired =>
        MilkStatus.expired,
      (MilkStatus.expired, MilkAction.discard) => MilkStatus.discarded,
      (MilkStatus.checkedOut, MilkAction.undoCheckOut)
          when _activeStatuses.contains(restoreStatus) =>
        restoreStatus!,
      _ => throw const MilkTransitionFailure('transition_not_allowed'),
    };

    return MilkTransition(
      from: currentStatus,
      to: target,
      action: action,
      eventType: _eventType(action),
      occurredAtUtc: atUtc,
    );
  }

  MilkStatusEventType _eventType(MilkAction action) => switch (action) {
    MilkAction.startThawing => MilkStatusEventType.thawingStarted,
    MilkAction.checkOut => MilkStatusEventType.checkedOut,
    MilkAction.markExpired => MilkStatusEventType.expired,
    MilkAction.discard => MilkStatusEventType.discarded,
    MilkAction.undoCheckOut => MilkStatusEventType.checkOutUndone,
  };

  static const _activeStatuses = {
    MilkStatus.frozenInStock,
    MilkStatus.refrigeratedInStock,
    MilkStatus.thawing,
  };
}

class MilkTransition {
  const MilkTransition({
    required this.from,
    required this.to,
    required this.action,
    required this.eventType,
    required this.occurredAtUtc,
  });

  final MilkStatus from;
  final MilkStatus to;
  final MilkAction action;
  final MilkStatusEventType eventType;
  final DateTime occurredAtUtc;
}

class MilkTransitionFailure implements Exception {
  const MilkTransitionFailure(this.code);

  final String code;

  @override
  String toString() => 'MilkTransitionFailure($code)';
}
