import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:graphics_lab6/models/light.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:vector_math/vector_math.dart' as vm;

class AppPainter extends CustomPainter {
  final Model polyhedron;
  final Camera camera;
  final Light light;
  final bool lightMode;
  final bool secretFeature;
  late List<List<double>> _zBuffer;

  late List<List<({Color color, Offset pos})?>> _pixels;

  static final _colors = List.generate(
      50,
      (_) =>
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
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

  AppPainter({
    required this.polyhedron,
    required this.camera,
    required this.secretFeature,
    required this.lightMode,
    required this.light,
  });

  late final Matrix _view, _projection;

  @override
  void paint(Canvas canvas, Size size) {
    _view = Matrix.view(camera.eye, camera.target, camera.up);
    _projection = Matrix.cameraPerspective(camera.fov, size.width / size.height,
        camera.nearPlane, camera.farPlane);

    _zBuffer = List.generate(size.height.toInt(),
        (_) => List.filled(size.width.toInt(), double.infinity));
    _pixels = List.generate(
        size.height.toInt(), (_) => List.filled(size.width.toInt(), null));

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
        point.updateWithVector(Matrix.point(point) * _projection);
      }
    }
    final projectedPolyhedron =
        polyhedron.getTransformed(_view).getTransformed(_projection);
    canvas.drawLine(MainBloc.point3DToOffset(xAxis.start, size),
        MainBloc.point3DToOffset(xAxis.end, size), _axisPaint);
    _xLabel.paint(canvas, MainBloc.point3DToOffset(xAxis.end, size));
    canvas.drawLine(MainBloc.point3DToOffset(yAxis.start, size),
        MainBloc.point3DToOffset(yAxis.end, size), _axisPaint);
    _yLabel.paint(canvas, MainBloc.point3DToOffset(yAxis.end, size));
    canvas.drawLine(MainBloc.point3DToOffset(zAxis.start, size),
        MainBloc.point3DToOffset(zAxis.end, size), _axisPaint);
    _zLabel.paint(canvas, MainBloc.point3DToOffset(zAxis.end, size));

    if (lightMode) {
      final forNormals = SplayTreeMap<Point3D, List<Point3D>>(Point3D.comparator);
      final normals = SplayTreeMap<Point3D, Point3D>(Point3D.comparator);
      for (int i = 0; i < projectedPolyhedron.polygons.length; ++i) {
        var curPolygon = polyhedron.polygons[i];
        var camVector = curPolygon.center - camera.eye;
        if (curPolygon.normal.dot(camVector) < 0) continue;

        for (Point3D point in curPolygon.points) {
          if (!forNormals.containsKey(point)) {
            forNormals[point] = List<Point3D>.empty(growable: true);
          }
          forNormals[point]!.add(curPolygon.normal.normalized());
        }
      }

      forNormals.forEach((point, normalsList) {
        var x = 0.0;
        var y = 0.0;
        var z = 0.0;
        for (var normal in normalsList) {
          x += normal.x;
          y += normal.y;
          z += normal.z;
        }
        final len = normalsList.length;
        normals[point] = Point3D(x / len, y / len, z / len);
      });

      for (int i = 0; i < projectedPolyhedron.polygons.length; ++i) {
        var curPolygon = polyhedron.polygons[i];
        var camVector = curPolygon.center - camera.eye;
        if (curPolygon.normal.dot(camVector) < 0) continue;

        final p0 = projectedPolyhedron.polygons[i].points[0];
        final p1 = projectedPolyhedron.polygons[i].points[1];
        final p2 = projectedPolyhedron.polygons[i].points[2];

        double intensity0 = lambertIntensity(lightVector(p0), normals[p0]!);
        double intensity1 = lambertIntensity(lightVector(p1), normals[p1]!);
        double intensity2 = lambertIntensity(lightVector(p2), normals[p2]!);

        Color color0 = Color.fromRGBO((light.color.x * intensity0).round(),
            (light.color.y * intensity0).round(), (light.color.z * intensity0).round(), 1.0);
        Color color1 = Color.fromRGBO((light.color.x * intensity1).round(),
            (light.color.y * intensity1).round(), (light.color.z * intensity1).round(), 1.0);
        Color color2 = Color.fromRGBO((light.color.x * intensity2).round(),
            (light.color.y * intensity2).round(), (light.color.z * intensity2).round(), 1.0);

        drawShadedTriangle(
          size: size,
          canvas: canvas,
          color0: color0,
          point3d0: p0,
          color1: color1,
          point3d1: p1,
          color2: color2,
          point3d2: p2,
          light: light,
        );
      }
      for (int i = 0; i < _pixels.length; ++i) {
        for (int j = 0; j < _pixels[i].length; ++j) {
          if (_pixels[i][j] != null) {
            canvas.drawPoints(PointMode.points, [_pixels[i][j]!.pos],
                _paint..color = _pixels[i][j]!.color);
          }
        }
      }
      return;
    }

    for (int i = 0; i < projectedPolyhedron.polygons.length; ++i) {
      var curPolygon = polyhedron.polygons[i];
      var camVector = curPolygon.center - camera.eye;
      if (curPolygon.normal.dot(camVector) < 0) continue;

      drawTriangle(
        size: size,
        canvas: canvas,
        point3d0: projectedPolyhedron.polygons[i].points[0],
        point3d1: projectedPolyhedron.polygons[i].points[1],
        point3d2: projectedPolyhedron.polygons[i].points[2],
        color: _colors[i % _colors.length],
        texture: projectedPolyhedron.texture,
      );
      // for (var j = 1; j < projectedPolyhedron.polygons[i].points.length; ++j) {
      //   canvas.drawLine(
      //       MainBloc.point3DToOffset(
      //           projectedPolyhedron.polygons[i].points[j - 1], size),
      //       MainBloc.point3DToOffset(
      //           projectedPolyhedron.polygons[i].points[j], size),
      //       _polyhedronPaint);
      // }
      // canvas.drawLine(
      //     MainBloc.point3DToOffset(
      //         projectedPolyhedron.polygons[i].points.first, size),
      //     MainBloc.point3DToOffset(
      //         projectedPolyhedron.polygons[i].points.last, size),
      //     _polyhedronPaint);
    }
    for (int i = 0; i < _pixels.length; ++i) {
      for (int j = 0; j < _pixels[i].length; ++j) {
        if (_pixels[i][j] != null) {
          canvas.drawPoints(PointMode.points, [_pixels[i][j]!.pos],
              _paint..color = _pixels[i][j]!.color);
        }
      }
    }
  }

  Point3D lightVector(Point3D point) {
    return Point3D(
        light.pos.x - point.x, light.pos.y - point.y, light.pos.z - point.z); //?
  }

  double lambertIntensity(Point3D lightVector, Point3D normal) {
    var cos =  (lightVector.x * normal.x +
            lightVector.y * normal.y +
            lightVector.z * normal.z) /
        (lightVector.length() * normal.length());
    return max(0,cos);
  }

  static final _paint = Paint()
    ..strokeWidth = 2
    ..blendMode = BlendMode.src
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.fill;

  void drawTriangle({
    required Size size,
    required Canvas canvas,
    required Point3D point3d0,
    required Point3D point3d1,
    required Point3D point3d2,
    required Color color,
    required img.Image? texture,
  }) {
    Offset p0 = MainBloc.point3DToOffset(point3d0, size);
    Offset p1 = MainBloc.point3DToOffset(point3d1, size);
    Offset p2 = MainBloc.point3DToOffset(point3d2, size);

    Offset textureCoord0 = Offset(0.0, texture?.width.toDouble() ?? 0.0);
    Offset textureCoord1 = Offset(0.0, 0.0);
    Offset textureCoord2 = Offset(texture?.height.toDouble() ?? 0.0, 0.0);

    if (p0.dy < p1.dy) {
      (point3d0, point3d1) = (point3d1, point3d0);
      (p0, p1) = (p1, p0);
      (textureCoord0, textureCoord1) = (textureCoord1, textureCoord0);
    }
    if (p0.dy < p2.dy) {
      (point3d0, point3d2) = (point3d2, point3d0);
      (p0, p2) = (p2, p0);
      (textureCoord0, textureCoord2) = (textureCoord2, textureCoord0);
    }
    if (p1.dy < p2.dy) {
      (point3d1, point3d2) = (point3d2, point3d1);
      (p1, p2) = (p2, p1);
      (textureCoord1, textureCoord2) = (textureCoord2, textureCoord1);
    }

    double totalHeight = (p0.dy - p2.dy);
    for (double i = 0; i < totalHeight; i++) {
      i = min(i, totalHeight);

      bool secondHalf = i > p0.dy - p1.dy || p1.dy == p0.dy;
      double segmentHeight = (secondHalf ? p1.dy - p2.dy : p0.dy - p1.dy);

      double alpha = i.toDouble() / totalHeight.toDouble();
      double beta =
          (i - (secondHalf ? p0.dy - p1.dy : 0)).toDouble() / segmentHeight;

      Offset l = p0 + (p2 - p0) * alpha;
      Offset left = Offset(l.dx.floorToDouble(), l.dy.floorToDouble());

      Offset r = secondHalf ? p1 + (p2 - p1) * beta : p0 + (p1 - p0) * beta;
      Offset right = Offset(r.dx.floorToDouble(), r.dy.floorToDouble());

      double leftZ = (point3d0 + (point3d2 - point3d0) * alpha).z;
      double rightZ = secondHalf
          ? (point3d1 + (point3d2 - point3d1) * beta).z
          : (point3d0 + (point3d1 - point3d0) * beta).z;

      Offset textureCoordL =
          textureCoord0 + (textureCoord2 - textureCoord0) * alpha;
      Offset textureCoordR = secondHalf
          ? textureCoord1 + (textureCoord2 - textureCoord1) * beta
          : textureCoord0 + (textureCoord1 - textureCoord0) * beta;

      if (left.dx > right.dx) {
        (left, right) = (right, left);
        (leftZ, rightZ) = (rightZ, leftZ);
        (textureCoordL, textureCoordR) = (textureCoordR, textureCoordL);
      }

      for (double j = left.dx; j < right.dx; j += 1) {
        j = min(j, right.dx);

        double ratio = (left.dx - right.dx).abs() < 1
            ? 1
            : (j - left.dx.toInt()).toDouble() / (right.dx - left.dx);

        Offset point = left + (right - left) * ratio;

        //Offset point = Offset(p.dx, p.dy);

        Offset textureCoord =
            textureCoordL + (textureCoordR - textureCoordL) * ratio;

        double z = leftZ + (rightZ - leftZ) * ratio;

        if (point.dy.toInt() > 0 &&
            point.dy.toInt() < _zBuffer.length &&
            point.dx.toInt() > 0 &&
            point.dx.toInt() < _zBuffer[0].length &&
            _zBuffer[point.dy.toInt()][point.dx.toInt()] > z) {
          _zBuffer[point.dy.toInt()][point.dx.toInt()] = z;

          var curPixel = texture?.getPixel(
            textureCoord.dx.toInt() % texture.width,
            textureCoord.dy.toInt() % texture.height,
          );
          Color curColor = curPixel != null
              ? Color.fromRGBO(
                  curPixel.r.toInt(), curPixel.g.toInt(), curPixel.b.toInt(), 1)
              : color;
          _pixels[point.dy.floor()][point.dx.floor()] =
              (color: curColor, pos: point);
        }
      }
    }
  }

  void drawShadedTriangle({
    required Size size,
    required Canvas canvas,
    required Color color0,
    required Point3D point3d0,
    required Color color1,
    required Point3D point3d1,
    required Color color2,
    required Point3D point3d2,
    required Light light,
  }) {
    Offset p0 = MainBloc.point3DToOffset(point3d0, size);
    Offset p1 = MainBloc.point3DToOffset(point3d1, size);
    Offset p2 = MainBloc.point3DToOffset(point3d2, size);
    if (p0.dy < p1.dy) {
      (point3d0, point3d1) = (point3d1, point3d0);
      (p0, p1) = (p1, p0);
      (color0, color1) = (color1, color0);
    }
    if (p0.dy < p2.dy) {
      (point3d0, point3d2) = (point3d2, point3d0);
      (p0, p2) = (p2, p0);
      (color0, color2) = (color2, color0);
    }
    if (p1.dy < p2.dy) {
      (point3d1, point3d2) = (point3d2, point3d1);
      (p1, p2) = (p2, p1);
      (color1, color2) = (color2, color1);
    }

    double totalHeight = (p0.dy - p2.dy);
    for (double i = 0; i < totalHeight; i++) {
      i = min(i, totalHeight);

      bool secondHalf = i > p0.dy - p1.dy || p1.dy == p0.dy;
      double segmentHeight = (secondHalf ? p1.dy - p2.dy : p0.dy - p1.dy);

      double alpha = i.toDouble() / totalHeight.toDouble();
      double beta =
          (i - (secondHalf ? p0.dy - p1.dy : 0)).toDouble() / segmentHeight;

      Offset l = p0 + (p2 - p0) * alpha;
      Color lColor = interpolateColor(alpha, color0, color2);
      Offset left = Offset(l.dx.floorToDouble(), l.dy.floorToDouble());

      Offset r = secondHalf ? p1 + (p2 - p1) * beta : p0 + (p1 - p0) * beta;
      Color rColor = interpolateColor(beta, secondHalf ? color1 : color0, secondHalf ? color2 : color1);
      Offset right = Offset(r.dx.floorToDouble(), r.dy.floorToDouble());

      double leftZ = (point3d0 + (point3d2 - point3d0) * alpha).z;
      double rightZ = secondHalf
          ? (point3d1 + (point3d2 - point3d1) * beta).z
          : (point3d0 + (point3d1 - point3d0) * beta).z;

      if (left.dx > right.dx) {
        (left, right) = (right, left);
        (lColor, rColor) = (rColor, lColor);
        (leftZ, rightZ) = (rightZ, leftZ);
      }

      for (double j = left.dx; j < right.dx; j += 1) {
        j = min(j, right.dx);

        double ratio = (left.dx - right.dx).abs() < 1
            ? 1
            : (j - left.dx.toInt()).toDouble() / (right.dx - left.dx);

        Offset point = left + (right - left) * ratio;

        double z = leftZ + (rightZ - leftZ) * ratio;

        if (point.dy.toInt() > 0 &&
            point.dy.toInt() < _zBuffer.length &&
            point.dx.toInt() > 0 &&
            point.dx.toInt() < _zBuffer[0].length &&
            _zBuffer[point.dy.toInt()][point.dx.toInt()] > z) {
          _zBuffer[point.dy.toInt()][point.dx.toInt()] = z;
          _pixels[point.dy.floor()][point.dx.floor()] =
              (color: interpolateColor(ratio, lColor, rColor), pos: point);
        }
      }
    }
  }

  Color interpolateColor(double coef, Color color1, Color color2) {
    return Color.fromRGBO(
      (color1.red + coef * (color2.red - color1.red)).round(),
      (color1.green + coef * (color2.green - color1.green)).round(),
      (color1.blue + coef * (color2.blue - color1.blue)).round(),
      1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
