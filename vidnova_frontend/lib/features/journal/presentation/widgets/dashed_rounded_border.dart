import 'package:flutter/material.dart';

class DashedRoundedBorder extends StatelessWidget {
  final BorderRadius borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Widget child;

  const DashedRoundedBorder({
    super.key,
    required this.borderRadius,
    required this.color,
    required this.child,
    this.strokeWidth = 1,
    this.dashWidth = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        borderRadius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedRRectPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = borderRadius.toRRect(Offset.zero & size);
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
