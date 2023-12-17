import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphics_lab6/models/ray_camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primitives.dart';

class Ray {
  final Point3D start, direction;
  const Ray({required this.start, required this.direction});
}

class Intersection {
  final double z;
  final Point3D hit;
  final Point3D normal;
  final bool inside;

  const Intersection(
      {required this.z,
      required this.hit,
      required this.normal,
      required this.inside});
}

abstract interface class IObject {
  Point3D get objectColor;

  double get specularStrength;

  double get shininess;

  double get reflectivity;

  double get transparency;

  double get refractiveIndex;

  Intersection? intersect(
      {required Ray ray,
      required RayCamera camera,
      required Matrix view,
      required Matrix projection});
}

class Light {
  Point3D position;
  double width;
  double height;
  double step;
  Point3D color;

  Light(
      {required this.width,
      required this.height,
      required this.step,
      required this.position,
      required this.color});
}

class Model implements IPoints, IObject {
  final List<Polygon> polygons;
  @override
  final List<Point3D> points;
  final List<List<int>> polygonsByIndexes;
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

  Model(
      {required this.points,
      required this.polygonsByIndexes,
      required this.color,
      this.shininess = 8,
      this.specularStrength = 0.5,
      this.reflectivity = 0.0,
      this.transparency = 0.0,
      this.refractiveIndex = 1.05})
      : polygons = [] {
    for (var polygonIndexes in polygonsByIndexes) {
      polygons.add(Polygon(List.generate(
          polygonIndexes.length, (i) => points[polygonIndexes[i]])));
    }
  }

  @override
  Point3D get objectColor =>
      Point3D(color.red / 255, color.green / 255, color.blue / 255, 1.0);

  @override
  Intersection? intersect(
      {required Ray ray,
      required RayCamera camera,
      required Matrix view,
      required Matrix projection}) {
    Intersection? nearestRes;
    double nearestZ = double.infinity;
    for (var polygon in polygons) {
      // var camVector = polygon.center - camera.eye;
      // if (polygon.normal.dot(camVector) < 0) continue;

      var res = polygon.intersect(ray);
      if (res == null) {
        continue;
      }

      final z = (res - ray.start).length();
      if (z < nearestZ) {
        nearestZ = z;
        nearestRes = Intersection(
            inside: ray.direction.dot(-polygon.normal) > 0,
            normal: -polygon.normal,
            hit: res,
            z: z);
      }
    }
    return nearestRes;
  }

  Point3D get center {
    var sum = Point3D.zero();
    for (var point in points) {
      sum = sum + point;
    }
    return sum / points.length;
  }

  Model getTransformed(Matrix transform) {
    final res = copy();
    for (var point in res.points) {
      point.updateWithVector(Matrix.point(point) * transform);
    }
    return res;
  }

  Model copy() {
    return Model(
        reflectivity: reflectivity,
        shininess: shininess,
        specularStrength: specularStrength,
        color: color,
        transparency: transparency,
        refractiveIndex: refractiveIndex,
        points: List.generate(points.length, (index) => points[index].copy()),
        polygonsByIndexes: polygonsByIndexes);
  }

  Model concat(Model other) {
    List<Point3D> resPoints = [];
    List<List<int>> resIndexes = [];

    for (var p in points) {
      resPoints.add(p.copy());
    }
    for (var p in other.points) {
      resPoints.add(p.copy());
    }

    for (var pol in polygonsByIndexes) {
      resIndexes.add(List.from(pol));
    }
    int len = points.length;
    for (var pol in other.polygonsByIndexes) {
      resIndexes.add(pol.map((e) => e + len).toList());
    }

    return Model(
        color: color, points: resPoints, polygonsByIndexes: resIndexes);
  }

  Model.cube({
    required Color color,
    double specularStrength = 0.0,
    double shininess = 8,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            specularStrength: specularStrength,
            shininess: shininess,
            points: [
              Point3D(1, 0, 0),
              Point3D(1, 1, 0),
              Point3D(0, 1, 0),
              Point3D(0, 0, 0),
              Point3D(0, 0, 1),
              Point3D(0, 1, 1),
              Point3D(1, 1, 1),
              Point3D(1, 0, 1),
            ],
            color: color,
            polygonsByIndexes: [
              [0, 1, 2],
              [2, 3, 0],
              [5, 2, 1],
              [1, 6, 5],
              [4, 5, 6],
              [6, 7, 4],
              [3, 4, 7],
              [7, 0, 3],
              [7, 6, 1],
              [1, 0, 7],
              [3, 2, 5],
              [5, 4, 3],
            ]);

  Model.tetrahedron(Color color)
      : this(points: [
          Point3D(1, 0, 0),
          Point3D(0, 0, 1),
          Point3D(0, 1, 0),
          Point3D(1, 1, 1),
        ], polygonsByIndexes: [
          [0, 2, 1],
          [1, 2, 3],
          [0, 3, 2],
          [0, 1, 3]
        ], color: color);
}
