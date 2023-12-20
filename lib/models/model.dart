import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primitives.dart';

class Ray {
  final Point3D start, direction;
  const Ray({required this.start, required this.direction});
}

class Intersection {
  final double depth;
  final Point3D hit;
  final Point3D normal;
  final bool inside;

  const Intersection(
      {required this.depth,
      required this.hit,
      required this.normal,
      required this.inside});
}

abstract interface class IObject {
  Point3D get objectColor;

  double get reflectivity;

  double get transparency;

  double get refractiveIndex;

  Intersection? intersect(
      {required Ray ray,
      required Camera camera,
      required Matrix view,
      required Matrix projection});
}

class Light {
  Point3D position;
  Point3D color;

  Light({required this.position, required this.color});
}

class Model implements IPoints, IObject {
  final List<Polygon> polygons;
  @override
  final List<Point3D> points;
  final List<List<int>> polygonsByIndexes;
  final Color color;
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
      required Camera camera,
      required Matrix view,
      required Matrix projection}) {
    Intersection? nearestRes;
    double nearestZ = double.infinity;
    for (var polygon in polygons) {
      var res = polygon.intersect(ray);
      if (res == null) {
        continue;
      }

      final depth = (res - ray.start).length();
      if (depth < nearestZ) {
        nearestZ = depth;
        nearestRes = Intersection(
            inside: ray.direction.dot(-polygon.normal) > 0,
            normal: -polygon.normal,
            hit: res,
            depth: depth);
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
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
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

  Model.tetrahedron({
    required Color color,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            points: [
              Point3D(1, 0, 0),
              Point3D(0, 0, 1),
              Point3D(0, 1, 0),
              Point3D(1, 1, 1),
            ],
            polygonsByIndexes: [
              [0, 2, 1],
              [1, 2, 3],
              [0, 3, 2],
              [0, 1, 3]
            ],
            color: color);

  Model.octahedron({
    required Color color,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            points: [
              Point3D(0.5, 1, 0.5),
              Point3D(0.5, 0.5, 1),
              Point3D(0, 0.5, 0.5),
              Point3D(0.5, 0.5, 0),
              Point3D(1, 0.5, 0.5),
              Point3D(0.5, 0, 0.5),
            ],
            polygonsByIndexes: [
              [0, 4, 1],
              [0, 3, 4],
              [0, 2, 3],
              [0, 1, 2],
              [5, 1, 4],
              [5, 4, 3],
              [5, 3, 2],
              [5, 2, 1],
            ],
            color: color);

  static double phi = (1 + sqrt(5)) / 2;
  static double iphi = 1 / phi;
  Model.icosahedron({
    required Color color,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            points: [
              Point3D(0, phi, 1), // 0
              Point3D(0, phi, -1), // 1
              Point3D(phi, 1, 0), // 2
              Point3D(-phi, 1, 0), // 3
              Point3D(1, 0, phi), // 4
              Point3D(1, 0, -phi), // 5
              Point3D(-1, 0, phi), // 6
              Point3D(-1, 0, -phi), // 7
              Point3D(phi, -1, 0), // 8
              Point3D(-phi, -1, 0), // 9
              Point3D(0, -phi, 1), // 10
              Point3D(0, -phi, -1), // 11
            ].map((e) => e / phi).toList(),
            polygonsByIndexes: [
              [0, 1, 2],
              [0, 3, 1],
              [0, 2, 4],
              [0, 6, 3],
              [0, 4, 6],
              [1, 5, 2],
              [1, 3, 7],
              [1, 7, 5],
              [2, 8, 4],
              [2, 5, 8],
              [3, 6, 9],
              [3, 9, 7],
              [4, 10, 6],
              [4, 8, 10],
              [5, 7, 11],
              [5, 11, 8],
              [6, 10, 9],
              [7, 9, 11],
              [8, 11, 10],
              [9, 10, 11],
            ],
            color: color);

  Model.dodecahedron({
    required Color color,
    double reflectivity = 0.0,
    double transparency = 0.0,
  }) : this(
            reflectivity: reflectivity,
            transparency: transparency,
            points: [
              Point3D(1, 1, 1), // 0
              Point3D(1, 1, -1), // 1
              Point3D(1, -1, 1), // 2
              Point3D(1, -1, -1), // 3
              Point3D(-1, 1, 1), // 4
              Point3D(-1, 1, -1), // 5
              Point3D(-1, -1, 1), // 6
              Point3D(-1, -1, -1), // 7
              Point3D(0, phi, iphi), // 8
              Point3D(0, phi, -iphi), // 9
              Point3D(0, -phi, iphi), // 10
              Point3D(0, -phi, -iphi), // 11
              Point3D(iphi, 0, phi), // 12
              Point3D(-iphi, 0, phi), // 13
              Point3D(iphi, 0, -phi), // 14
              Point3D(-iphi, 0, -phi), // 15
              Point3D(phi, iphi, 0), // 16
              Point3D(phi, -iphi, 0), // 17
              Point3D(-phi, iphi, 0), // 18
              Point3D(-phi, -iphi, 0), // 19
            ].map((e) => e / phi).toList(),
            polygonsByIndexes: [
              ..._splitIntoTriangles([8, 9, 1, 16, 0]),
              ..._splitIntoTriangles([4, 18, 5, 9, 8]),
              ..._splitIntoTriangles([2, 17, 3, 11, 10]),
              ..._splitIntoTriangles([10, 11, 7, 19, 6]),
              ..._splitIntoTriangles([12, 13, 4, 8, 0]),
              ..._splitIntoTriangles([2, 10, 6, 13, 12]),
              ..._splitIntoTriangles([1, 9, 5, 15, 14]),
              ..._splitIntoTriangles([14, 15, 7, 11, 3]),
              ..._splitIntoTriangles([16, 17, 2, 12, 0]),
              ..._splitIntoTriangles([1, 14, 3, 17, 16]),
              ..._splitIntoTriangles([4, 13, 6, 19, 18]),
              ..._splitIntoTriangles([18, 19, 7, 15, 5]),
            ],
            color: color);

  static List<List<int>> _splitIntoTriangles(List<int> indices) {
    List<List<int>> triangles = [];
    for (int i = 1; i < indices.length - 1; i++) {
      triangles.add([indices[0], indices[i], indices[i + 1]]);
    }
    return triangles;
  }
}
