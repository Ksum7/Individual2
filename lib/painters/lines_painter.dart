import 'package:flutter/material.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primitives.dart';

class LinesPainter extends CustomPainter {
  final Model polyhedron;
  final Camera camera;

  late List<List<({Color color, Offset pos})?>> _pixels;

  static final _axisPaint = Paint()
    ..strokeWidth = 1
    ..color = Colors.deepPurple;
  static const _labelStyle = TextStyle(color: Colors.white, fontSize: 16);
  static final _xLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "X",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);
  static final _yLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "Y",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);
  static final _zLabel = TextPainter(
      text: const TextSpan(
    style: _labelStyle,
    text: "Z",
  ))
    ..textDirection = TextDirection.ltr
    ..layout(maxWidth: 0, minWidth: 0);

  LinesPainter({
    required this.polyhedron,
    required this.camera,
  });

  late final Matrix _view, _projection;
  static final _polyhedronPaint = Paint()
    ..strokeWidth = 2
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    _view = Matrix.view(camera.eye, camera.target, camera.up);
    _projection = Matrix.cameraPerspective(camera.fov, size.width / size.height,
        camera.nearPlane, camera.farPlane);

    final xAxis = Edge(Point3D(0, 0, 0), Point3D(2, 0, 0));
    final yAxis = Edge(Point3D(0, 0, 0), Point3D(0, 2, 0));
    final zAxis = Edge(Point3D(0, 0, 0), Point3D(0, 0, 2));
    for (var el in <IPoints>[xAxis, yAxis, zAxis]) {
      for (var point in el.points) {
        point.updateWithVector(Matrix.point(point) * _view);
        point.updateWithVector(Matrix.point(point) * _projection);
      }
    }
    canvas.drawLine(MainBloc.point3DToOffset(xAxis.start, size),
        MainBloc.point3DToOffset(xAxis.end, size), _axisPaint);
    _xLabel.paint(canvas, MainBloc.point3DToOffset(xAxis.end, size));

    canvas.drawLine(MainBloc.point3DToOffset(yAxis.start, size),
        MainBloc.point3DToOffset(yAxis.end, size), _axisPaint);
    _yLabel.paint(canvas, MainBloc.point3DToOffset(yAxis.end, size));

    canvas.drawLine(MainBloc.point3DToOffset(zAxis.start, size),
        MainBloc.point3DToOffset(zAxis.end, size), _axisPaint);
    _zLabel.paint(canvas, MainBloc.point3DToOffset(zAxis.end, size));

    _pixels = List.generate(
        size.height.toInt(), (_) => List.filled(size.width.toInt(), null));

    final projectedPolyhedron =
        polyhedron.getTransformed(_view).getTransformed(_projection);

    for (int i = 0; i < projectedPolyhedron.polygons.length; ++i) {
      for (var j = 1;
          j < projectedPolyhedron.polygons[i].points.length + 1;
          ++j) {
        canvas.drawLine(
            MainBloc.point3DToOffset(
                projectedPolyhedron.polygons[i].points[j - 1], size),
            MainBloc.point3DToOffset(
                projectedPolyhedron.polygons[i]
                    .points[j % projectedPolyhedron.polygons[i].points.length],
                size),
            _polyhedronPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
