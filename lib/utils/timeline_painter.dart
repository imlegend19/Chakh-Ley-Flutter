import 'dart:ui';

import 'package:flutter/material.dart';

class TimelinePainter extends CustomPainter {
  final Color lineColor;
  final Color circleColor;
  final Color backgroundColor;
  final bool firstElement;
  final bool lastElement;
  final bool isCancel;
  final Animation<double> controller;
  final Animation<double> height;

  TimelinePainter(
      {@required this.lineColor,
      @required this.circleColor,
      @required this.backgroundColor,
      @required this.isCancel,
      this.firstElement = false,
      this.lastElement = false,
      this.controller})
      : height = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.45, 1.0, curve: Curves.ease),
          ),
        ),
        super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    _centerElementPaint(canvas, size);
  }

  void _centerElementPaint(Canvas canvas, Size size) {
    Paint lineStroke = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    if (firstElement && lastElement) {
      // Do nothing
    } else if (firstElement) {
      Offset offsetCenter = size.center(Offset(0.0, -4.0));
      Offset offsetBottom = size.bottomCenter(Offset(0.0, 0.0));
      Offset renderOffset = Offset(
          offsetBottom.dx, offsetBottom.dy * (0.5 + (controller.value / 2)));
      canvas.drawLine(offsetCenter, renderOffset, lineStroke);
    } else if (lastElement) {
      Offset offsetTopCenter = size.topCenter(Offset(0.0, 0.0));
      Offset offsetCenter = size.center(Offset(0.0, -4.0));
      Offset renderOffset =
          Offset(offsetCenter.dx, offsetCenter.dy * controller.value);
      canvas.drawLine(offsetTopCenter, renderOffset, lineStroke);
    } else {
      Offset offsetTopCenter = size.topCenter(Offset(0.0, 0.0));
      Offset offsetBottom = size.bottomCenter(Offset(0.0, 0.0));
      Offset renderOffset =
          Offset(offsetBottom.dx, offsetBottom.dy * controller.value);
      canvas.drawLine(offsetTopCenter, renderOffset, lineStroke);
    }

    if (isCancel) {
      Paint paint = Paint();
      paint.color = Colors.red;
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(12.5, 46), Offset(27, 30), paint);

      canvas.drawLine(Offset(27, 46), Offset(12.5, 30), paint);
    } else {
      Paint circleFill = Paint()
        ..color = circleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(size.center(Offset(0.0, -8.0)), 10.0, circleFill);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
