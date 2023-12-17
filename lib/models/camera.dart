import 'package:graphics_lab6/models/primitives.dart';

class Camera {
  final Point3D eye, target, up;
  final double fov, aspect, nearPlane, farPlane;

  Camera({
    required this.eye,
    required this.target,
    required this.up,
    required this.aspect,
    this.nearPlane = 1,
    this.farPlane = 1000,
    this.fov = 45,
  });

  Camera copyWith({
    Point3D? eye,
    Point3D? target,
    Point3D? up,
    double? nearPlane,
    double? farPlane,
    double? fov,
    double? aspect,
  }) =>
      Camera(
        aspect: aspect ?? this.aspect,
        eye: eye ?? this.eye,
        target: target ?? this.target,
        up: up ?? this.up,
        nearPlane: nearPlane ?? this.nearPlane,
        farPlane: farPlane ?? this.farPlane,
        fov: fov ?? this.fov,
      );
}
