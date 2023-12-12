import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:image/image.dart';

abstract interface class IPoints {
  List<Point3D> get points;
}

class Point3D {
  double x, y, z;
  double h;

  static get comparator => (Point3D a, Point3D b) =>
      "${a.x}${a.y}${a.z}".compareTo("${a.x}${a.y}${a.z}");

  Point3D(this.x, this.y, this.z, [this.h = 1]);

  Point3D.zero() : this(0, 0, 0);

  Point3D.fromVector(Matrix m)
      : x = m[0][0],
        y = m[0][1],
        z = m[0][2],
        h = m[0][3];

  updateWithVector(Matrix matrix) {
    x = matrix[0][0];
    y = matrix[0][1];
    z = matrix[0][2];
    h = matrix[0][3];
  }

  Point3D copy() => Point3D(x, y, z);

  Point3D normalized() {
    double len = length();
    return Point3D(x / len, y / len, z / len);
  }

  Point3D cross(Point3D other) {
    return Point3D(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  double dot(Point3D other) {
    return x * other.x + y * other.y + z * other.z;
  }

  Point3D operator *(double value) {
    return Point3D(x * value, y * value, z * value);
  }

  Point3D operator -(Point3D other) {
    return Point3D(x - other.x, y - other.y, z - other.z, h);
  }

  Point3D operator -() {
    return Point3D(-x, -y, -z, h);
  }

  Point3D operator +(Point3D other) {
    return Point3D(x + other.x, y + other.y, z + other.z, h);
  }

  Point3D operator /(num d) {
    return Point3D(x / d, y / d, z / d);
  }

  double length() {
    return sqrt(x * x + y * y + z * z);
  }

  @override
  String toString() {
    return '${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${z.toStringAsFixed(2)}';
  }
}

class Line {
  double a, b, c;

  Line(this.a, this.b, this.c);

  Line.fromPointsXZ(Point3D p1, Point3D p2)
      : a = (p2.z - p1.z),
        b = (p1.x - p2.x),
        c = p1.x * (p1.z - p2.z) + p1.z * (p2.x - p1.x);

  Line.perpendicularXZ(Line l, Point3D p)
      : a = -l.b,
        b = l.a,
        c = l.b * p.x - l.a * p.z;

  (double, double) intersect(Line other) {
    return (
      (b * other.c - other.b * c) / (a * other.b - other.a * b),
      (c * other.a - other.c * a) / (a * other.b - other.a * b)
    );
  }
}

class Edge implements IPoints {
  final Point3D start, end;

  Edge(this.start, this.end);

  @override
  List<Point3D> get points => [start, end];
}

class Polygon implements IPoints {
  @override
  final List<Point3D> points;

  Point3D? _normal;
  Point3D? _center;

  Polygon(this.points);

  Point3D get normal {
    if (_normal != null) return _normal!;

    var v1 = points[1] - points[0];
    var v2 = points[2] - points[0];
    return v1.cross(v2);
  }

  Point3D get center {
    if (_center != null) return _center!;

    var sum = Point3D.zero();
    for (var point in points) {
      sum = sum + point;
    }
    return sum / points.length;
  }
}

class Model implements IPoints {
  final List<Polygon> polygons;
  Image? texture;
  @override
  final List<Point3D> points;
  final List<List<int>> polygonsByIndexes;

  Model(this.points, this.polygonsByIndexes, {this.texture}) : polygons = [] {
    for (var polygonIndexes in polygonsByIndexes) {
      polygons.add(Polygon(List.generate(
          polygonIndexes.length, (i) => points[polygonIndexes[i]])));
    }
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
    return Model(List.generate(points.length, (index) => points[index].copy()),
        polygonsByIndexes,
        texture: texture);
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

    return Model(resPoints, resIndexes);
  }

  static Model get cube => Model([
        Point3D(1, 0, 0),
        Point3D(1, 1, 0),
        Point3D(0, 1, 0),
        Point3D(0, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 1),
        Point3D(1, 1, 1),
        Point3D(1, 0, 1),
      ], [
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

  static get tetrahedron => Model([
        Point3D(1, 0, 0),
        Point3D(0, 0, 1),
        Point3D(0, 1, 0),
        Point3D(1, 1, 1),
      ], [
        [0, 2, 1],
        [1, 2, 3],
        [0, 3, 2],
        [0, 1, 3]
      ]);

  static get octahedron => Model([
        Point3D(0.5, 1, 0.5),
        Point3D(0.5, 0.5, 1),
        Point3D(0, 0.5, 0.5),
        Point3D(0.5, 0.5, 0),
        Point3D(1, 0.5, 0.5),
        Point3D(0.5, 0, 0.5),
      ], [
        [0, 4, 1],
        [0, 3, 4],
        [0, 2, 3],
        [0, 1, 2],
        [5, 1, 4],
        [5, 4, 3],
        [5, 3, 2],
        [5, 2, 1],
      ]);

  static double phi = (1 + sqrt(5)) / 2;

  static get icosahedron => Model(
          [
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
          [
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
          ]);

  static get dodecahedron {
    final double iphi = 1 / phi;
    return Model(
        [
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
        [
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
        ]);
  }

  static List<List<int>> _splitIntoTriangles(List<int> indices) {
    List<List<int>> triangles = [];
    for (int i = 1; i < indices.length - 1; i++) {
      triangles.add([indices[0], indices[i], indices[i + 1]]);
    }
    return triangles;
  }

  Future<bool> saveFile() async {
    var path = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['obj'],
    );
    if (path == null) {
      return false;
    }
    final buffer = StringBuffer();
    for (var point in points) {
      buffer.write(
          "v ${point.x.toStringAsFixed(9)} ${point.y.toStringAsFixed(9)} ${point.z.toStringAsFixed(9)}\n");
    }
    buffer.writeln();
    for (var polygonIndexes in polygonsByIndexes) {
      buffer.write("f ");
      var idcs = [polygonIndexes[0], polygonIndexes[2], polygonIndexes[1]];
      for (var index in idcs) {
        buffer.write("${index + 1} ");
      }
      buffer.write("\n");
    }
    if (!path.endsWith(".obj")) {
      path = "$path.obj";
    }
    await File(path).writeAsString(buffer.toString());
    return true;
  }

  static final _doubleRE = RegExp(r"[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?");

  static final RegExp _objVertexRE = RegExp(
    "v (?<x>${_doubleRE.pattern}) (?<y>${_doubleRE.pattern}) (?<z>${_doubleRE.pattern})( ${_doubleRE.pattern})?\\D",
  );

  static final _intSlashRE = RegExp(r"([0-9]+)(/[0-9]*)?(/[0-9]+)?");

  static final RegExp _objFaceRE = RegExp(
    "f (${_intSlashRE.pattern} )*(${_intSlashRE.pattern})\\D",
  );

  static Future<Model?> fromFile() async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['obj'],
      withData: true,
    );

    if (pick == null || !pick.isSinglePick) {
      return null;
    }

    String fileContent = utf8.decode(pick.files.first.bytes!);
    final points = List<Point3D>.empty(growable: true);
    final polygonsByIndexes = List<List<int>>.empty(growable: true);

    // print("points ${_objVertexRE.allMatches(fileContent).length}");
    for (RegExpMatch match in _objVertexRE.allMatches(fileContent)) {
      points.add(
        Point3D(
          double.parse(match.namedGroup("x")!),
          double.parse(match.namedGroup("y")!),
          double.parse(match.namedGroup("z")!),
        ),
      );

      // print("point ${match.namedGroup("x")!} ${match.namedGroup("y")!} ${match.namedGroup("z")!}");
    }

    // print("faces ${_objFaceRE.allMatches(fileContent).length}");
    for (RegExpMatch match in _objFaceRE.allMatches(fileContent)) {
      var polygon = List<int>.empty(growable: true);
      // print(match.group(0)!);
      for (RegExpMatch m in _intSlashRE.allMatches(match.group(0)!)) {
        polygon.add(int.parse(m.group(1)!) - 1);
      }
      int t = polygon[1];
      polygon[1] = polygon[2];
      polygon[2] = t;
      polygonsByIndexes.add(polygon);
      // print("polygon $polygon");
    }

    //return points;
    return Model(points, polygonsByIndexes);
  }
}
