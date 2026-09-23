import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/domain/services/weekly_milk_flow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyFlowChart extends StatefulWidget {
  const WeeklyFlowChart({required this.flow, super.key});

  final WeeklyMilkFlow flow;

  @override
  State<WeeklyFlowChart> createState() => _WeeklyFlowChartState();
}

class _WeeklyFlowChartState extends State<WeeklyFlowChart> {
  static final _captionFormat = DateFormat('M月d日');
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final flow = widget.flow;
    final selected = (_selectedIndex ?? flow.days.length - 1).clamp(
      0,
      flow.days.length - 1,
    );
    final day = flow.days[selected];
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近一周', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${_captionFormat.format(flow.days.first.date)} – ${_captionFormat.format(flow.days.last.date)}',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendDot(
                  color: AppTheme.coral,
                  label: '入库 ${flow.intakeMl} mL',
                ),
                _LegendDot(
                  color: AppTheme.lake,
                  label: '出库 ${flow.checkoutMl} mL',
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 188,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    key: const Key('weekly-flow-plot'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      setState(() {
                        _selectedIndex = _ChartGeometry.indexFor(
                          details.localPosition.dx,
                          constraints.maxWidth,
                          flow.days.length,
                        );
                      });
                    },
                    child: CustomPaint(
                      painter: _FlowChartPainter(
                        flow: flow,
                        selectedIndex: selected,
                        intakeColor: AppTheme.coral,
                        checkoutColor: AppTheme.lake,
                        gridColor: const Color(0xFFEAD8D5),
                        labelColor: muted,
                        bandColor: const Color(0xFFFFE7E3),
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_captionFormat.format(day.date)}  入库 ${day.intakeMl} mL · 出库 ${day.checkoutMl} mL',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ChartGeometry {
  static const left = 40.0;
  static const right = 8.0;
  static const top = 10.0;
  static const bottom = 24.0;

  static int indexFor(double dx, double width, int count) {
    if (count <= 1) return 0;
    final plotWidth = math.max(1.0, width - left - right);
    final t = ((dx - left) / plotWidth).clamp(0.0, 1.0);
    return (t * (count - 1)).round().clamp(0, count - 1);
  }
}

class _FlowChartPainter extends CustomPainter {
  _FlowChartPainter({
    required this.flow,
    required this.selectedIndex,
    required this.intakeColor,
    required this.checkoutColor,
    required this.gridColor,
    required this.labelColor,
    required this.bandColor,
  });

  final WeeklyMilkFlow flow;
  final int selectedIndex;
  final Color intakeColor;
  final Color checkoutColor;
  final Color gridColor;
  final Color labelColor;
  final Color bandColor;

  static final _axisFormat = DateFormat('M/d');

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _ChartGeometry.left,
      _ChartGeometry.top,
      size.width - _ChartGeometry.right,
      size.height - _ChartGeometry.bottom,
    );
    final peak = flow.days.fold<int>(
      0,
      (max, day) => math.max(max, math.max(day.intakeMl, day.checkoutMl)),
    );
    final axisMax = _axisMax(peak);
    final count = flow.days.length;

    final selectedX = _x(plot, selectedIndex, count);
    final band = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(selectedX, plot.center.dy),
            width: math.max(18, plot.width / count * 0.72),
            height: plot.height,
          ),
          const Radius.circular(6),
        ),
      );
    canvas.save();
    canvas.clipRect(plot);
    canvas.drawPath(band, Paint()..color = bandColor);
    canvas.restore();

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final fraction in const [0.0, 0.5, 1.0]) {
      final y = plot.bottom - plot.height * fraction;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintLabel(
        canvas,
        _formatAxis((axisMax * fraction).round()),
        Offset(plot.left - 6, y),
        alignRight: true,
      );
    }

    _drawSeries(canvas, plot, axisMax, (day) => day.checkoutMl, checkoutColor);
    _drawSeries(canvas, plot, axisMax, (day) => day.intakeMl, intakeColor);

    for (var index = 0; index < count; index++) {
      _paintLabel(
        canvas,
        _axisFormat.format(flow.days[index].date),
        Offset(_x(plot, index, count), plot.bottom + 6),
        below: true,
      );
    }
  }

  void _drawSeries(
    Canvas canvas,
    Rect plot,
    int axisMax,
    int Function(DailyMilkVolume day) valueOf,
    Color color,
  ) {
    final count = flow.days.length;
    final path = Path();
    final points = <Offset>[];
    for (var index = 0; index < count; index++) {
      final point = Offset(
        _x(plot, index, count),
        plot.bottom - plot.height * (valueOf(flow.days[index]) / axisMax),
      );
      points.add(point);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final fill = Path.from(path)
      ..lineTo(points.last.dx, plot.bottom)
      ..lineTo(points.first.dx, plot.bottom)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final dot = Paint()..color = color;
    final ring = Paint()..color = const Color(0xFFFFFBFA);
    for (var index = 0; index < points.length; index++) {
      final radius = index == selectedIndex ? 4.5 : 3.2;
      canvas.drawCircle(points[index], radius + 1.4, ring);
      canvas.drawCircle(points[index], radius, dot);
    }
  }

  double _x(Rect plot, int index, int count) {
    if (count <= 1) return plot.center.dx;
    return plot.left + plot.width * index / (count - 1);
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset anchor, {
    bool alignRight = false,
    bool below = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 10, height: 1),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final dx = alignRight
        ? anchor.dx - painter.width
        : anchor.dx - painter.width / 2;
    final dy = below ? anchor.dy : anchor.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  int _axisMax(int peak) {
    if (peak <= 0) return 100;
    final padded = math.max(peak + 1, (peak * 1.12).ceil());
    final exponent = (math.log(padded) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toInt();
    final normalized = padded / magnitude;
    final nice = normalized <= 1
        ? 1
        : normalized <= 2
        ? 2
        : normalized <= 5
        ? 5
        : 10;
    return nice * magnitude;
  }

  String _formatAxis(int value) {
    if (value >= 1000 && value % 1000 == 0) return '${value ~/ 1000}k';
    return '$value';
  }

  @override
  bool shouldRepaint(covariant _FlowChartPainter oldDelegate) {
    if (oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.intakeColor != intakeColor ||
        oldDelegate.checkoutColor != checkoutColor ||
        oldDelegate.flow.days.length != flow.days.length) {
      return true;
    }
    for (var index = 0; index < flow.days.length; index++) {
      final previous = oldDelegate.flow.days[index];
      final next = flow.days[index];
      if (previous.date != next.date ||
          previous.intakeMl != next.intakeMl ||
          previous.checkoutMl != next.checkoutMl) {
        return true;
      }
    }
    return false;
  }
}
