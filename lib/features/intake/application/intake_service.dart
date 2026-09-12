import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/domain/models/food_tag.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_models.dart';
import 'package:breast_milk/platform/printer/printer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final intakeServiceProvider = Provider<IntakeService>((ref) {
  return IntakeService(
    repository: ref.watch(milkRepositoryProvider),
    printer: ref.watch(printerGatewayProvider),
  );
});

final intakeFoodTagsProvider = FutureProvider<List<FoodTag>>((ref) {
  return ref.watch(milkRepositoryProvider).listFoodTags();
});

class IntakeService {
  IntakeService({
    required this.repository,
    required this.printer,
    DateTime Function()? nowUtc,
  }) : _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  final MilkRepository repository;
  final PrinterGateway printer;
  final DateTime Function() _nowUtc;

  Future<IntakeResult> save(IntakeRequest request) async {
    final now = _nowUtc();
    _validate(request, now);
    final record = await repository.create(
      CreateMilkRecordCommand(
        storedAtUtc: request.storedAt.toUtc(),
        timezoneOffsetMinutes: request.storedAt.timeZoneOffset.inMinutes,
        amountMl: request.amountMl,
        storageMode: request.storageMode,
        foodTagIds: request.foodTagIds,
        foodNotes: request.foodNotes,
        createdAtUtc: now,
      ),
    );
    if (!request.printAfterSave) {
      return IntakeResult(record: record, printState: IntakePrintState.skipped);
    }
    return _print(
      record,
      foodSummary: _foodSummary(request.foodNames, request.foodNotes),
    );
  }

  Future<IntakeResult> retryPrint(
    MilkRecord record, {
    required Iterable<String> foodNames,
  }) {
    return _print(
      record,
      foodSummary: _foodSummary(foodNames, record.foodNotes),
    );
  }

  Future<IntakeResult> reprint(
    MilkRecord record, {
    required Iterable<String> foodNames,
  }) {
    return _print(
      record,
      foodSummary: _foodSummary(foodNames, record.foodNotes),
      isReprint: true,
    );
  }

  Future<FoodTag> saveFoodTag(String name) {
    return repository.saveFoodTag(name: name, atUtc: _nowUtc());
  }

  Future<IntakeResult> _print(
    MilkRecord record, {
    required String foodSummary,
    bool isReprint = false,
  }) async {
    try {
      await repository.updatePrintStatus(
        id: record.id,
        status: PrintStatus.printing,
        updatedAtUtc: _nowUtc(),
      );
      await printer.printMilkLabel(
        _labelFor(record, foodSummary, isReprint: isReprint),
      );
      await repository.updatePrintStatus(
        id: record.id,
        status: PrintStatus.printed,
        updatedAtUtc: _nowUtc(),
      );
      final printed = await repository.findById(record.id) ?? record;
      return IntakeResult(
        record: printed,
        printState: IntakePrintState.printed,
      );
    } catch (error) {
      // The record is already committed. A printer failure must only change
      // print state so the same label can be retried without creating a bag.
      await repository.updatePrintStatus(
        id: record.id,
        status: PrintStatus.failed,
        updatedAtUtc: _nowUtc(),
      );
      final failed = await repository.findById(record.id) ?? record;
      return IntakeResult(
        record: failed,
        printState: IntakePrintState.failed,
        printerFailure: error is PrinterFailure
            ? error
            : const PrinterFailure('print_failed'),
      );
    }
  }

  MilkLabelData _labelFor(
    MilkRecord record,
    String foodSummary, {
    required bool isReprint,
  }) {
    final wallTime = record.storedAtUtc.add(
      Duration(minutes: record.timezoneOffsetMinutes),
    );
    return MilkLabelData(
      id: record.id,
      date: DateFormat('yyyy-MM-dd').format(wallTime),
      time: DateFormat('HH:mm').format(wallTime),
      amount: '${record.amountMl} mL',
      storage: switch (record.storageMode) {
        MilkStorageMode.frozen => '-21°C 冷冻',
        MilkStorageMode.refrigerated => '3°C 冷藏',
      },
      food: foodSummary,
      isReprint: isReprint,
    );
  }

  String _foodSummary(Iterable<String> names, String notes) {
    final parts = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .take(2)
        .toList();
    final trimmedNotes = notes.trim();
    if (parts.isEmpty && trimmedNotes.isNotEmpty) parts.add(trimmedNotes);
    return parts.isEmpty ? '无' : parts.join(' ');
  }

  void _validate(IntakeRequest request, DateTime nowUtc) {
    if (!nowUtc.isUtc) throw const IntakeFailure('utc_required');
    if (request.amountMl <= 0) throw const IntakeFailure('invalid_amount');
    if (request.amountMl > 9999) throw const IntakeFailure('amount_too_large');
    if (request.storedAt.toUtc().isAfter(nowUtc)) {
      throw const IntakeFailure('future_stored_at');
    }
  }
}

class IntakeRequest {
  const IntakeRequest({
    required this.storedAt,
    required this.amountMl,
    required this.storageMode,
    required this.printAfterSave,
    this.foodTagIds = const [],
    this.foodNames = const [],
    this.foodNotes = '',
  });

  final DateTime storedAt;
  final int amountMl;
  final MilkStorageMode storageMode;
  final List<String> foodTagIds;
  final List<String> foodNames;
  final String foodNotes;
  final bool printAfterSave;
}

enum IntakePrintState { skipped, printed, failed }

class IntakeResult {
  const IntakeResult({
    required this.record,
    required this.printState,
    this.printerFailure,
  });

  final MilkRecord record;
  final IntakePrintState printState;
  final PrinterFailure? printerFailure;
}

class IntakeFailure implements Exception {
  const IntakeFailure(this.code);

  final String code;
}
