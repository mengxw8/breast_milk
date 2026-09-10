import 'package:breast_milk/domain/models/milk_enums.dart';

class MilkStatusEvent {
  MilkStatusEvent({
    required this.id,
    required this.milkId,
    required this.type,
    required this.occurredAtUtc,
    required this.fromStatus,
    required this.toStatus,
    this.metadata = const {},
  }) : assert(occurredAtUtc.isUtc);

  final String id;
  final String milkId;
  final MilkStatusEventType type;
  final DateTime occurredAtUtc;
  final MilkStatus? fromStatus;
  final MilkStatus toStatus;
  final Map<String, Object?> metadata;
}
