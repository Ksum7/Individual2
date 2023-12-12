import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Path path;

  CurvePainter({
    required this.path,
  });
  static const _labelStyle = TextStyle(color: Colors.black, fontSize: 16);
  static final _xLabel = TextPainter(
      text: const TextSpan(
        style: _labelStyle,
        text: "X",
      )
  )..textDirection = TextDirection.ltr..layout(
      maxWidth: 0,
      minWidth: 0
  );
  static final _yLabel = TextPainter(
      text: const TextSpan(
        style: _labelStyle,
        text: "Y",
      )
  )..textDirection = TextDirection.ltr..layout(
      maxWidth: 0,
      minWidth: 0
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), Paint()..strokeWidth = 2);
    _xLabel.paint(canvas, Offset(size.width - 30, size.height/2 - 30));
    canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), Paint()..strokeWidth = 2);
    _yLabel.paint(canvas, Offset(size.width/2 + 20, 20));
    canvas.drawPath(path, Paint()..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}