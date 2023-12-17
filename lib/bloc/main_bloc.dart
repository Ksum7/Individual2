import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/primitives.dart';
import 'package:meta/meta.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc()
      : super(
          MoveState(
            model: Model([], []),
            camera: Camera(
              aspect: 1,
              eye: Point3D(5, 5, 5),
              target: Point3D(0, 0, 0),
              up: Point3D(0, 1, 0),
            ),
          ),
        ) {
    on<ShowMessageEvent>((event, emit) {
      emit((state as MoveState).copyWith(message: event.message));
    });
    on<UpdateCamera>(_onUpdateCamera);
    on<CameraRotationEvent>(_onCameraRotation);
    on<CameraMoveEvent>(_onCameraMove);
    on<CameraScaleEvent>(_onCameraScale);
    on<SwitchModeEvent>(_onSwitchMode);
  }

  static const _pixelRatio = 100;

  static Offset point3DToOffset(Point3D point3d, Size size) {
    return Offset((point3d.x / point3d.h + 1.0) * 0.5 * size.width,
        (1.0 - point3d.y / point3d.h) * 0.5 * size.height);
  }

  static Point3D offsetToPoint3D(Offset offset, Size size) {
    return Point3D((offset.dx - size.width / 2) / _pixelRatio,
        -(offset.dy - size.height / 2) / _pixelRatio, 0);
  }

  void _onUpdateCamera(UpdateCamera event, Emitter emit) {
    emit((state as MoveState).copyWith(camera: event.camera));
  }

  static const double sensitivity = 0.003;

  void _onCameraRotation(CameraRotationEvent event, Emitter emit) {
    final camera = (state as MoveState).camera;
    Point3D direction = camera.target - camera.eye;
    double radius = direction.length();

    double theta = atan2(direction.z, direction.x);
    double phi = acos(direction.y / radius);

    theta += event.delta.dx * sensitivity;
    phi += event.delta.dy * sensitivity;
    phi = max(0.1, min(pi - 0.1, phi));
    direction.x = radius * sin(phi) * cos(theta);
    direction.y = radius * cos(phi);
    direction.z = radius * sin(phi) * sin(theta);

    final eye = camera.target - direction;
    emit((state as MoveState).copyWith(camera: camera.copyWith(eye: eye)));
  }

  void _onCameraScale(CameraScaleEvent event, Emitter emit) {
    final camera = (state as MoveState).camera;
    Point3D direction = camera.target - camera.eye;
    double distance = direction.length();
    distance += event.delta * sensitivity;

    final eye = camera.target - direction.normalized() * distance;
    emit((state as MoveState).copyWith(camera: camera.copyWith(eye: eye)));
  }

  void _onCameraMove(CameraMoveEvent event, Emitter emit) {
    final camera = (state as MoveState).camera;
    final move = event.delta;

    Point3D forward = (camera.target - camera.eye).normalized();
    Point3D right = forward.cross(camera.up).normalized();
    Point3D up = camera.up.normalized();

    var mv = forward * move.z + right * move.x + up * move.y;

    emit((state as MoveState).copyWith(
      camera: camera.copyWith(
        eye: camera.eye + mv,
        target: camera.target + mv,
      ),
    ));
  }

  void _onSwitchMode(SwitchModeEvent event, Emitter emit) {
    if (event.isLines) {
      _handleLines(event, emit);
    } else {
      _handleRays(event, emit);
    }
  }

  void _handleLines(SwitchModeEvent event, Emitter emit) {
    if (state is MoveState) return;
  }

  void _handleRays(SwitchModeEvent event, Emitter emit) {
    if (state is DrawState) return;
  }
}
