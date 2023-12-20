import 'dart:math';
import 'dart:ui';

import 'package:graphics_lab6/models/primitives.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'package:graphics_lab6/models/model.dart';

class Camera {
  final Point3D eye, target, up;
  final double fov, nearPlane, farPlane;
  final random = Random();
  Camera({
    required this.eye,
    required this.target,
    required this.up,
    this.nearPlane = 1,
    this.farPlane = 100,
    this.fov = 60,
  });

  Ray getRay(double x, double y, int width, int height) {
    double scale = tan(vm.radians(fov) * 0.5);
    Point3D forward = (target - eye).normalized();
    Point3D right = -up.cross(forward).normalized();
    Point3D localUp = -forward.cross(right).normalized();
    Point3D rayDirection = forward +
        right * ((2 * x / width - 1) * (width / height) * scale) +
        localUp * ((1 - 2 * y / height) * scale);
    return Ray(start: eye, direction: rayDirection.normalized());
  }

  List<({Offset pixel, Ray ray})> getRays(int width, int height) {
    final pixelRays = <({Offset pixel, Ray ray})>[];
    for (double x = 0; x < width; ++x) {
      for (double y = 0; y < height; ++y) {
        pixelRays.add((pixel: Offset(x, y), ray: getRay(x, y, width, height)));
      }
    }
    return pixelRays;
  }

  Camera copyWith({
    Point3D? eye,
    Point3D? target,
    Point3D? up,
    double? nearPlane,
    double? farPlane,
    double? fov,
  }) =>
      Camera(
        eye: eye ?? this.eye,
        target: target ?? this.target,
        up: up ?? this.up,
        nearPlane: nearPlane ?? this.nearPlane,
        farPlane: farPlane ?? this.farPlane,
        fov: fov ?? this.fov,
      );
}
