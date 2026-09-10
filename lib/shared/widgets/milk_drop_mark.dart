import 'dart:math' as math;

import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MilkDropMark extends StatelessWidget {
  const MilkDropMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: '吨吨吨，两大一小奶滴标志',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: const _MilkDropPainter()),
      ),
    );
  }
}

class _MilkDropPainter extends CustomPainter {
  const _MilkDropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 72;
    canvas.scale(scale);
    _drawDrop(canvas, const Offset(19, 11), 19, true);
    _drawDrop(canvas, const Offset(53, 11), 19, true);
    _drawDrop(canvas, const Offset(36, 32), 13, false);
  }

  void _drawDrop(Canvas canvas, Offset tip, double radius, bool hasFace) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(
        tip.dx - radius * 0.26,
        tip.dy + radius * 0.48,
        tip.dx - radius,
        tip.dy + radius * 0.9,
        tip.dx - radius,
        tip.dy + radius * 1.35,
      )
      ..cubicTo(
        tip.dx - radius,
        tip.dy + radius * 2.15,
        tip.dx - radius * 0.5,
        tip.dy + radius * 2.55,
        tip.dx,
        tip.dy + radius * 2.55,
      )
      ..cubicTo(
        tip.dx + radius * 0.5,
        tip.dy + radius * 2.55,
        tip.dx + radius,
        tip.dy + radius * 2.15,
        tip.dx + radius,
        tip.dy + radius * 1.35,
      )
      ..cubicTo(
        tip.dx + radius,
        tip.dy + radius * 0.9,
        tip.dx + radius * 0.26,
        tip.dy + radius * 0.48,
        tip.dx,
        tip.dy,
      )
      ..close();

    canvas.drawShadow(path, const Color(0x335A3030), 2.5, false);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFCF7));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppTheme.coral,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(tip.dx - radius * 0.35, tip.dy + radius * 0.9),
        width: radius * 0.34,
        height: radius * 0.64,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    if (!hasFace) return;
    final faceY = tip.dy + radius * 1.48;
    final facePaint = Paint()..color = AppTheme.ink;
    canvas.drawCircle(Offset(tip.dx - radius * 0.27, faceY), 1.15, facePaint);
    canvas.drawCircle(Offset(tip.dx + radius * 0.27, faceY), 1.15, facePaint);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(tip.dx, faceY + radius * 0.17),
        width: radius * 0.42,
        height: radius * 0.3,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..color = AppTheme.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
