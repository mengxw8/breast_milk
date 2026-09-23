import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/domain/services/weekly_milk_flow.dart';
import 'package:breast_milk/features/statistics/presentation/weekly_flow_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('点击某一天显示当天入库和出库奶量', (tester) async {
    final flow = WeeklyMilkFlow([
      for (var day = 17; day <= 23; day++)
        DailyMilkVolume(
          date: DateTime(2026, 9, day),
          intakeMl: day == 17
              ? 80
              : day == 23
              ? 120
              : 0,
          checkoutMl: day == 23 ? 40 : 0,
        ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: WeeklyFlowChart(flow: flow)),
      ),
    );

    expect(find.text('最近一周'), findsOneWidget);
    expect(find.text('入库 200 mL'), findsOneWidget);
    expect(find.text('出库 40 mL'), findsOneWidget);
    expect(find.textContaining('9月23日  入库 120 mL · 出库 40 mL'), findsOneWidget);

    final plot = find.byKey(const Key('weekly-flow-plot'));
    await tester.tapAt(tester.getTopLeft(plot) + const Offset(40, 40));
    await tester.pump();

    expect(find.textContaining('9月17日  入库 80 mL · 出库 0 mL'), findsOneWidget);
  });
}
