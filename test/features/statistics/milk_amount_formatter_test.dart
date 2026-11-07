import 'package:breast_milk/features/statistics/presentation/milk_amount_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1000毫升及以下保持毫升显示', () {
    expect(formatStatisticsMilkAmount(0), '0 mL');
    expect(formatStatisticsMilkAmount(1000), '1000 mL');
  });

  test('超过1000毫升按升显示并保留两位小数', () {
    expect(formatStatisticsMilkAmount(1001), '1.00 L');
    expect(formatStatisticsMilkAmount(1250), '1.25 L');
    expect(formatStatisticsMilkAmount(9999), '10.00 L');
  });

  test('图表点值仅在超过1000毫升时附带升单位', () {
    expect(formatStatisticsMilkChartValue(1000), '1000');
    expect(formatStatisticsMilkChartValue(1250), '1.25 L');
  });
}
