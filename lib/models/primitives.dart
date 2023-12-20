import 'dart:math';

import 'package:graphics_lab6/models/matrix.dart';
import 'package:image/image.dart';
import 'package:graphics_lab6/models/model.dart';

abstract interface class IPoints {
  List<Point3D> get points;
}

class Point3D {
  double x, y, z;
  double h;

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

  Point3D multiply(Point3D other) {
    return Point3D(x * other.x, y * other.y, z * other.z);
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

  void limitTop(double value) {
    x = min(x, value);
    y = min(y, value);
    z = min(z, value);
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
    return v1.cross(v2).normalized();
  }

  Point3D get center {
    if (_center != null) return _center!;

    var sum = Point3D.zero();
    for (var point in points) {
      sum = sum + point;
    }
    return sum / points.length;
  }

  Point3D? intersect(Ray ray) {
    var e1 = points[1] - points[0];
    var e2 = points[2] - points[0];
    var pVec = ray.direction.cross(e2);
    double det = e1.dot(pVec);
    if (det.abs() < 1e-18) {
      return null;
    }

    double invDet = 1.0 / det;
    var tVec = ray.start - points[0];
    double u = tVec.dot(pVec) * invDet;
    if (u < 0.0 || u > 1.0) {
      return null;
    }

    var q = tVec.cross(e1);
    double v = invDet * (ray.direction.dot(q));
    if (v < 0.0 || u + v > 1.0) {
      return null;
    }

    double t = invDet * (e2.dot(q));
    if (t <= 1e-18) {
      return null;
    }

    return ray.start + ray.direction * t;
  }
}
