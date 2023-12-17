import 'dart:math';
import 'dart:ui';

import 'package:graphics_lab6/models/ray_camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primitives.dart';
import 'package:graphics_lab6/models/ray_model.dart';

class Sphere implements IObject {
  final Point3D center;
  final double radius;
  final Color color;
  @override
  final double specularStrength;
  @override
  final double shininess;
  @override
  final double reflectivity;
  @override
  final double transparency;
  @override
  final double refractiveIndex;

  Sphere(
      {required this.color,
      required this.radius,
      required this.center,
      this.shininess = 8,
      this.specularStrength = 0.5,
      this.reflectivity = 0.0,
      this.transparency = 0.0,
      this.refractiveIndex = 1.03});

  @override
  Point3D get objectColor =>
      Point3D(color.red / 255, color.green / 255, color.blue / 255, 1.0);

  @override
  Intersection? intersect(
      {required Ray ray,
      required RayCamera camera,
      required Matrix view,
      required Matrix projection}) {
    Point3D oc = ray.start - center;
    double a = ray.direction.dot(ray.direction);
    double b = 2.0 * oc.dot(ray.direction);
    double c = oc.dot(oc) - radius * radius;
    double discriminant = b * b - 4 * a * c;

    if (discriminant < 0) {
      return null;
    } else {
      double t1 = (-b - sqrt(discriminant)) / (2 * a);
      double t2 = (-b + sqrt(discriminant)) / (2 * a);
      double t = t1 < t2 && t1 >= 0 ? t1 : t2;
      final intersection = ray.start + ray.direction * t;
      final normal = (intersection - center).normalized();
      if (t >= 0) {
        return Intersection(
            inside: ray.direction.dot(normal) > 0,
            normal: normal,
            hit: intersection,
            z: (intersection - ray.start).length());
      } else {
        return null;
      }
    }
  }
}
