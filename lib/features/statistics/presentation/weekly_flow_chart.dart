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
              height: 208,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final valueLabels = _pointValueLabels(
                    flow: flow,
                    size: chartSize,
                    intakeColor: AppTheme.coral,
                    checkoutColor: AppTheme.lake,
                  );
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
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          painter: _FlowChartPainter(
                            flow: flow,
                            selectedIndex: selected,
                            intakeColor: AppTheme.coral,
                            checkoutColor: AppTheme.lake,
                            gridColor: const Color(0xFFEAD8D5),
                            labelColor: muted,
                            bandColor: const Color(0xFFFFE7E3),
                          ),
                          size: chartSize,
                        ),
                        for (final label in valueLabels)
                          Positioned(
                            left: label.left,
                            top: label.top,
                            width: label.width,
                            height: _ChartGeometry.labelHeight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: label.color,
                                  fontSize: 10,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
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
  static const top = 26.0;
  static const bottom = 24.0;
  static const labelHeight = 12.0;
  static const labelLift = 7.0;

  static int indexFor(double dx, double width, int count) {
    if (count <= 1) return 0;
    final plotWidth = math.max(1.0, width - left - right);
    final t = ((dx - left) / plotWidth).clamp(0.0, 1.0);
    return (t * (count - 1)).round().clamp(0, count - 1);
  }

  static Rect plotOf(Size size) {
    return Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
  }

  static double x(Rect plot, int index, int count) {
    if (count <= 1) return plot.center.dx;
    return plot.left + plot.width * index / (count - 1);
  }

  static double y(Rect plot, int value, int axisMax) {
    return plot.bottom - plot.height * (value / axisMax);
  }

  static int axisMax(int peak) {
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
}

class _PointValueLabel {
  const _PointValueLabel({
    required this.left,
    required this.top,
    required this.width,
    required this.text,
    required this.color,
  });

  final double left;
  final double top;
  final double width;
  final String text;
  final Color color;
}

List<_PointValueLabel> _pointValueLabels({
  required WeeklyMilkFlow flow,
  required Size size,
  required Color intakeColor,
  required Color checkoutColor,
}) {
  final plot = _ChartGeometry.plotOf(size);
  final count = flow.days.length;
  final peak = flow.days.fold<int>(
    0,
    (max, day) => math.max(max, math.max(day.intakeMl, day.checkoutMl)),
  );
  final axisMax = _ChartGeometry.axisMax(peak);
  final spacing = count <= 1 ? plot.width : plot.width / (count - 1);
  final slotWidth = math.min(40.0, math.max(18.0, spacing - 2));

  double leftFor(double center) {
    final left = center - slotWidth / 2;
    return left.clamp(0.0, math.max(0.0, size.width - slotWidth));
  }

  final labels = <_PointValueLabel>[];
  for (var index = 0; index < count; index++) {
    final day = flow.days[index];
    final center = _ChartGeometry.x(plot, index, count);
    final intakeY = _ChartGeometry.y(plot, day.intakeMl, axisMax);
    final checkoutY = _ChartGeometry.y(plot, day.checkoutMl, axisMax);
    final tops = _labelTops(intakeY, checkoutY);
    labels.add(
      _PointValueLabel(
        left: leftFor(center),
        top: tops.$1,
        width: slotWidth,
        text: '${day.intakeMl}',
        color: intakeColor,
      ),
    );
    labels.add(
      _PointValueLabel(
        left: leftFor(center),
        top: tops.$2,
        width: slotWidth,
        text: '${day.checkoutMl}',
        color: checkoutColor,
      ),
    );
  }
  return labels;
}

(double, double) _labelTops(double intakeY, double checkoutY) {
  const height = _ChartGeometry.labelHeight;
  var intakeTop = intakeY - _ChartGeometry.labelLift - height;
  var checkoutTop = checkoutY - _ChartGeometry.labelLift - height;
  final overlaps =
      intakeTop < checkoutTop + height && checkoutTop < intakeTop + height;
  if (overlaps) {
    final higher = math.min(intakeY, checkoutY);
    final near = higher - _ChartGeometry.labelLift - height;
    final far = near - 1 - height;
    if (intakeY <= checkoutY) {
      intakeTop = near;
      checkoutTop = far;
    } else {
      checkoutTop = near;
      intakeTop = far;
    }
  }
  return (math.max(0, intakeTop), math.max(0, checkoutTop));
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
    final plot = _ChartGeometry.plotOf(size);
    final peak = flow.days.fold<int>(
      0,
      (max, day) => math.max(max, math.max(day.intakeMl, day.checkoutMl)),
    );
    final axisMax = _ChartGeometry.axisMax(peak);
    final count = flow.days.length;

    final selectedX = _ChartGeometry.x(plot, selectedIndex, count);
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
        Offset(_ChartGeometry.x(plot, index, count), plot.bottom + 6),
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
        _ChartGeometry.x(plot, index, count),
        _ChartGeometry.y(plot, valueOf(flow.days[index]), axisMax),
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
