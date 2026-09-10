import 'package:breast_milk/domain/services/milk_id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = MilkIdGenerator();

  test('生成16位纯数字编号且序号从01开始', () async {
    final id = await generator.generate(
      intakeLocalTime: DateTime(2026, 9, 10, 11, 57, 1),
      exists: (_) async => false,
    );

    expect(id, '2026091011570101');
    expect(RegExp(r'^\d{16}$').hasMatch(id), isTrue);
  });

  test('同秒编号冲突时递增序号', () async {
    final occupied = {
      '2026091011570101',
      '2026091011570102',
      '2026091011570103',
    };

    final id = await generator.generate(
      intakeLocalTime: DateTime(2026, 9, 10, 11, 57, 1),
      exists: (candidate) async => occupied.contains(candidate),
    );

    expect(id, '2026091011570104');
  });

  test('系统时间回拨时通过占用查询避免覆盖旧编号', () async {
    final olderId = await generator.generate(
      intakeLocalTime: DateTime(2026, 9, 10, 11, 57, 1),
      exists: (candidate) async => candidate.endsWith('01'),
    );

    expect(olderId, '2026091011570102');
  });

  test('同一秒99个序号全部占用时拒绝生成', () async {
    await expectLater(
      generator.generate(
        intakeLocalTime: DateTime(2026, 9, 10, 11, 57, 1),
        exists: (_) async => true,
      ),
      throwsA(
        isA<MilkIdGenerationFailure>().having(
          (failure) => failure.code,
          'code',
          'sequence_exhausted',
        ),
      ),
    );
  });
}
