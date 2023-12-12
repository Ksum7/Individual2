import 'package:flutter/material.dart';
import 'package:graphics_lab6/models/primtives.dart';

class Light {
  late final Point3D pos, direction, color;

  Light({Point3D? pos, Point3D? direction, Point3D? color,}) {
    this.pos = pos ?? Point3D(3, 3, 3);
    this.direction = direction ?? Point3D(1, 1, 1);
    this.color = color ?? Point3D(255,0,0);
  }
}