import 'package:flutter/material.dart';
import 'dart:ui';

class DottedBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets borderPadding;
  final double strokeWidth;
  final Color color;
  final List<double> dashPattern;
  final Radius radius;

  const DottedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const <double>[3, 1],
    this.padding = EdgeInsets.zero,
    this.borderPadding = EdgeInsets.zero,
    this.radius = Radius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(
            painter: _DottedBorderPainter(
              color: color,
              strokeWidth: strokeWidth,
              dashPattern: dashPattern,
              radius: radius,
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    if (radius.x > 0 || radius.y > 0) {
      path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), radius));
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    Path dashPath = _createDashedPath(path, dashPattern);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, List<double> dashArray) {
    Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      int index = 0;
      while (distance < metric.length) {
        final double len = dashArray[index % dashArray.length];
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
        index++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern ||
        oldDelegate.radius != radius;
  }
}
