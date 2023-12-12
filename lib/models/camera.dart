import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primtives.dart';

class Camera{
  final Point3D eye, target, up;
  final double fov, aspect, nearPlane, farPlane;
  // final Matrix view, projection, invertedView;
  // final bool isPerspective;

  Camera({
    required this.eye,
    required this.target,
    required this.up,
    required this.aspect,
    this.nearPlane = 1,
    this.farPlane = 1000,
    this.fov = 45,
    // this.isPerspective = true
  });//:view = Matrix.view(eye, target, up),
    // invertedView = Matrix.invertedView(eye, target, up),
    // projection = isPerspective ?
    //   Matrix.cameraPerspective(fov, aspect, nearPlane, farPlane)
    //   : Matrix.cameraOrthographic(nearPlane, farPlane);

  Camera copyWith({
    Point3D? eye,
    Point3D? target,
    Point3D? up,
    double? nearPlane,
    double? farPlane,
    double? fov,
    double? aspect,
  }) => Camera(
    aspect: aspect ?? this.aspect,
    eye: eye ?? this.eye,
    target: target ?? this.target,
    up: up ?? this.up,
    nearPlane: nearPlane ?? this.nearPlane,
    farPlane: farPlane ?? this.farPlane,
    fov: fov ?? this.fov,
  );
}