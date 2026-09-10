typedef MilkIdExists = Future<bool> Function(String id);

class MilkIdGenerator {
  const MilkIdGenerator();

  Future<String> generate({
    required DateTime intakeLocalTime,
    required MilkIdExists exists,
  }) async {
    if (intakeLocalTime.year < 1 || intakeLocalTime.year > 9999) {
      throw const MilkIdGenerationFailure('invalid_intake_time');
    }
    final prefix = [
      intakeLocalTime.year.toString().padLeft(4, '0'),
      intakeLocalTime.month.toString().padLeft(2, '0'),
      intakeLocalTime.day.toString().padLeft(2, '0'),
      intakeLocalTime.hour.toString().padLeft(2, '0'),
      intakeLocalTime.minute.toString().padLeft(2, '0'),
      intakeLocalTime.second.toString().padLeft(2, '0'),
    ].join();

    for (var sequence = 1; sequence <= 99; sequence++) {
      final candidate = '$prefix${sequence.toString().padLeft(2, '0')}';
      if (!await exists(candidate)) return candidate;
    }
    throw const MilkIdGenerationFailure('sequence_exhausted');
  }
}

class MilkIdGenerationFailure implements Exception {
  const MilkIdGenerationFailure(this.code);

  final String code;

  @override
  String toString() => 'MilkIdGenerationFailure($code)';
}
