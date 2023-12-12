import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:vector_math/vector_math.dart' as vm;


class FloatingHorizonPainter extends CustomPainter{
  final Camera camera;
  final double Function(double, double) func;
  final double min, max, step;
  final double pixelRatio;
  final bool secretFeature;


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

  FloatingHorizonPainter({
    required this.camera,
    required this.func,
    required this.min,
    required this.max,
    required this.step,
    required this.secretFeature,
    required this.pixelRatio
  });

  static const double crossStep = 0.02;
  late final Matrix _view;

  @override
  void paint(Canvas canvas, Size size) {
    _view = Matrix.view(camera.eye, camera.target, camera.up);

    _axisPaint.strokeWidth =
    secretFeature ? (Random().nextDouble() * 2 + 1.5) : 1;
    _axisPaint.color = secretFeature
        ? Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6)
        : Colors.deepPurple;
    final l = secretFeature ? (Random().nextDouble() * 3 + 2) : 2.0;
    final m = Matrix.rotation(vm.radians(Random().nextDouble() * 360),
        Point3D(1 / sqrt(3), 1 / sqrt(3), 1 / sqrt(3)));
    final xAxis = Edge(Point3D(0, 0, 0), Point3D(l, 0, 0));
    final yAxis = Edge(Point3D(0, 0, 0), Point3D(0, l, 0));
    final zAxis = Edge(Point3D(0, 0, 0), Point3D(0, 0, l));
    for (var el in <IPoints>[xAxis, yAxis, zAxis]) {
      for (var point in el.points) {
        if (secretFeature) {
          point.updateWithVector(Matrix.point(point) * m);
        }
        point.updateWithVector(Matrix.point(point) * _view);
      }
    }

    canvas.drawLine(_point3DToOffset(xAxis.start, size),
        _point3DToOffset(xAxis.end, size), _axisPaint);
    _xLabel.paint(canvas, _point3DToOffset(xAxis.end, size));
    canvas.drawLine(_point3DToOffset(yAxis.start, size),
        _point3DToOffset(yAxis.end, size), _axisPaint);
    _yLabel.paint(canvas,_point3DToOffset(yAxis.end, size));
    canvas.drawLine(_point3DToOffset(zAxis.start, size),
        _point3DToOffset(zAxis.end, size), _axisPaint);
    _zLabel.paint(canvas, _point3DToOffset(zAxis.end, size));

    final (sides, steps) = calcPoints();
    final horizonMin = List<double>.generate(
      steps.length, (index) => size.height
    );
    final horizonMax = List<double>.generate(
      steps.length, (index) => 0
    );
    final path = Path();
    for (int i = 0; i < sides.length; ++i){
      final left = sides[i][0];
      final leftProj = Point3D.fromVector(Matrix.point(left) * _view);
      final right = sides[i][1];
      final rightProj = Point3D.fromVector(Matrix.point(right) * _view);

      int leftInd = ((leftProj.x - steps.first) / crossStep).floor();
      int rightInd = steps.length - ((steps.last > rightProj.x ? (steps.last - rightProj.x):0) / crossStep).floor() - 1;
      final pointStep = (right - left) / (rightInd - leftInd);
      Point3D currPoint = Point3D(
        left.x,
        0,
        left.z
      );
      Offset? prevPoint;
      for (int ind = leftInd; ind <= rightInd; ind++){
        Point3D currFunc = Point3D(currPoint.x, func(currPoint.x, currPoint.z), currPoint.z);
        currPoint += pointStep;
        final cameraPoint = Point3D.fromVector(Matrix.point(currFunc) * _view);
        final canvasPoint = _point3DToOffset(cameraPoint, size);
        bool visible = false;
        if (canvasPoint.dy > horizonMax[ind]){
          horizonMax[ind] = canvasPoint.dy;
          visible = true;
        }
        if (canvasPoint.dy < horizonMin[ind]){
          horizonMin[ind] = canvasPoint.dy;
          visible = true;
        }
        if (visible){
          if (prevPoint != null){
            path.lineTo(canvasPoint.dx, canvasPoint.dy);
          } else {
            path.moveTo(canvasPoint.dx, canvasPoint.dy);
          }
          prevPoint = canvasPoint;
        } else {
          prevPoint = null;
        }
      }
    }
    canvas.drawPath(path, Paint()..strokeWidth = 1..color = Colors.white..style = PaintingStyle.stroke);
  }

  Offset _point3DToOffset(Point3D point3d, Size size) {
    return Offset(
        (point3d.x / point3d.h * pixelRatio + size.width / 2).roundToDouble(),
        (-point3d.y / point3d.h * pixelRatio + size.height / 2)
            .roundToDouble());
  }

  (List<List<Point3D>>, List<double>) calcPoints(){
    List<Point3D> corners = [
      Point3D(min, 0, min),
      Point3D(min, 0, max),
      Point3D(max, 0, max),
      Point3D(max, 0, min),
    ];

    final projectedCamera = Point3D(camera.eye.x, 0, camera.eye.z);
    final dist = sqrt(projectedCamera.x * projectedCamera.x + projectedCamera.z * projectedCamera.z);
    final ratio = dist/step;
    final stepPoint = - projectedCamera / ratio;
    int nearestIndex = 0;
    for (int i = 1; i < corners.length; ++i){
      if ( (Matrix.point(corners[i]) * _view).value[0][2].abs()
          < (Matrix.point(corners[nearestIndex]) * _view).value[0][2].abs()){
        nearestIndex = i;
      }
    }

    switch(nearestIndex){
      case 0: corners = [
        Point3D(max, 0, min),
        Point3D(min, 0, min),
        Point3D(min, 0, max),
        Point3D(max, 0, max),
      ];
      case 1: corners = [
        Point3D(min, 0, min),
        Point3D(min, 0, max),
        Point3D(max, 0, max),
        Point3D(max, 0, min),
      ];
      case 2: corners = [
        Point3D(min, 0, max),
        Point3D(max, 0, max),
        Point3D(max, 0, min),
        Point3D(min, 0, min),
      ];
      default: corners = [
        Point3D(max, 0, max),
        Point3D(max, 0, min),
        Point3D(min, 0, min),
        Point3D(min, 0, max),
      ];
    }

    final main = Line.fromPointsXZ(stepPoint + corners[1], corners[1]);
    Line left = Line.fromPointsXZ(corners[1], corners[0]);
    Line right = Line.fromPointsXZ(corners[1], corners[2]);
    bool leftChanged = false;
    bool rightChanged = false;

    Point3D mostLeft = Point3D(double.infinity, 0, 0);
    Point3D mostRight = Point3D(double.negativeInfinity, 0, 0);

    final List<List<Point3D>> points = [];
    int ind = 1;
    while(true){
      final perpendicular = Line.perpendicularXZ(main, corners[1] + stepPoint * ind.toDouble());
      ind += 1;

      var (leftInterX, leftInterZ) = perpendicular.intersect(left);
      if (!leftChanged && !between(corners[0], corners[1], leftInterX, leftInterZ)){
        left = Line.fromPointsXZ(corners[0], corners[3]);
        leftChanged = true;
        (leftInterX, leftInterZ) = perpendicular.intersect(left);
      }

      var (rightInterX, rightInterZ) = perpendicular.intersect(right);
      if (!rightChanged && !between(corners[2], corners[1], rightInterX, rightInterZ)){
        right = Line.fromPointsXZ(corners[2], corners[3]);
        rightChanged = true;
        (rightInterX, rightInterZ) = perpendicular.intersect(right);
      }

      if (rightChanged && !between(corners[2], corners[3], rightInterX, rightInterZ)
          || leftChanged && !between(corners[0], corners[3], leftInterX, leftInterZ)){
        break;
      } else {
        Point3D rightProj = Point3D.fromVector(Matrix.point(Point3D(rightInterX, 0, rightInterZ)) * _view);
        Point3D leftProj = Point3D.fromVector(Matrix.point(Point3D(leftInterX, 0, leftInterZ)) * _view);
        if (leftProj.x > rightProj.x) {
          (leftProj, rightProj) = (rightProj, leftProj);
          points.add([Point3D(rightInterX, 0, rightInterZ), Point3D(leftInterX, 0, leftInterZ)]);
        } else {
          points.add([Point3D(leftInterX, 0, leftInterZ), Point3D(rightInterX, 0, rightInterZ)]);
        }
        if (mostLeft.x > leftProj.x){
          mostLeft = leftProj;
        }
        if (mostRight.x < rightProj.x){
          mostRight = rightProj;
        }
      }
    }
    List<double> steps = [];
    for (double x = mostLeft.x; x < mostRight.x; x += crossStep){
      steps.add(x < mostRight.x ? x : mostRight.x);
    }
    return (points, steps);
  }

  bool between(Point3D p1, Point3D p2, double x, double z){
    return (p1.x <= x && x <= p2.x || p2.x <= x && x <= p1.x) && (p1.z <= z && z <= p2.z || p2.z <= z && z <= p1.z);
  }

  (double, double) calcPerpendicular(double k, double b, Point3D point){
    double newK = -1/k;
    double newB = point.z - newK * point.x;
    return (newK, newB);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}