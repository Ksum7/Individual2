import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class RayPainter extends CustomPainter {
  late List<List<({Color color, Offset pos})?>> pixels;

  RayPainter({
    required this.pixels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pixels.length; ++i) {
      for (int j = 0; j < pixels[i].length; ++j) {
        if (pixels[i][j] != null) {
          canvas.drawPoints(ui.PointMode.points, [pixels[i][j]!.pos],
              _paint..color = pixels[i][j]!.color);
        }
      }
    }
  }

  static final _paint = Paint()
    ..strokeWidth = 2
    ..blendMode = BlendMode.src
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.fill;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
