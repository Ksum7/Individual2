import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphics_lab6/main.dart';
import 'package:graphics_lab6/models/camera.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/primitives.dart';
import 'package:graphics_lab6/models/model.dart';
import 'package:graphics_lab6/models/sphere.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc()
      : super(
          MoveState(
            model: buildLinesModel(
                buildScene(List.filled(9, Configuration(name: "")))),
            camera: Camera(
              eye: Point3D(1, 1, 6),
              target: Point3D(1, 1, 5.9),
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
    scene = buildScene(event.configurations);

    if (event.isLines) {
      _handleLines(event, emit);
    } else {
      _handleRays(event, emit);
    }
  }

  void _handleLines(SwitchModeEvent event, Emitter emit) {
    if (state is MoveState) return;
    var model = Model(points: [], polygonsByIndexes: [], color: Colors.black);
    for (var m in scene) {
      model = model.concat(m);
    }

    emit(MoveState(model: model, camera: state.camera));
  }

  void _handleRays(SwitchModeEvent event, Emitter emit) {
    print("!");
    if (state is DrawState) return;
    print("!!");
    _render(10);
    print("!!!");
  }

  List<Model> scene = [];

  final List<Light> lights = [
    Light(
      position: Point3D(1.7, 1.95, 0.3),
      color: Point3D(0.7, 0.7, 0.7),
    ),
    Light(
      position: Point3D(0.3, 1.95, 0.3),
      color: Point3D(0.7, 0.7, 0.7),
    ),
  ];

  final ambientLight = Point3D(0.05, 0.05, 0.05);
  int width = 0;
  int height = 0;
  Matrix _view = Matrix.unit();
  Matrix _projection = Matrix.unit();

  void _render(int depth) {
    List<List<({Color color, Offset pos})?>> pixels =
        List.generate(height, (_) => List.filled(width, null));

    _view = Matrix.view(state.camera.eye, state.camera.target, state.camera.up);
    _projection = Matrix.cameraPerspective(state.camera.fov, width / height,
        state.camera.nearPlane, state.camera.farPlane);

    for (var pixelRay in state.camera.getRays(width, height)) {
      final pixel = pixelRay.pixel;
      Point3D? color = _traceRay(pixelRay.ray, depth);

      if (color != null) {
        final resColor = Color.fromRGBO((color.x * 255).floor(),
            (color.y * 255).floor(), (color.z * 255).floor(), 1.0);

        pixels[pixel.dy.toInt()][pixel.dx.toInt()] =
            (color: resColor, pos: pixel);
      }
    }
    emit(DrawState(pixels: pixels, camera: state.camera));
  }

  Point3D? _traceRay(Ray ray, int depth) {
    if (depth <= 0) {
      return Point3D(0, 0, 0);
    }

    Model? intersectionModel;
    Intersection? nearestIntersection;

    for (var model in scene) {
      var intersection = model.intersect(
          camera: state.camera, projection: _projection, view: _view, ray: ray);
      if (intersection == null) {
        continue;
      }
      if (nearestIntersection == null ||
          intersection.depth < nearestIntersection.depth) {
        nearestIntersection = intersection;
        intersectionModel = model;
      }
    }

    if (nearestIntersection == null) return null;

    if (intersectionModel!.transparency > 0.1) {
      Point3D light = Point3D.zero();
      Ray? refractedRay =
          _refract(ray, nearestIntersection, intersectionModel.refractiveIndex);
      if (refractedRay != null) {
        light += (_traceRay(refractedRay, depth - 1) ?? Point3D(0, 0, 0)) *
            intersectionModel.transparency;
      }
      return light;
    }

    if (intersectionModel.reflectivity > 0.1) {
      Point3D reflectedRayDirection =
          _reflect(ray.direction, nearestIntersection.normal);
      Ray reflectedRay = Ray(
          start: nearestIntersection.hit + reflectedRayDirection * 0.001,
          direction: reflectedRayDirection);
      Point3D reflectedColor =
          _traceRay(reflectedRay, depth - 1) ?? Point3D(0, 0, 0);
      return reflectedColor * intersectionModel.reflectivity;
    }

    Point3D light = _calcLocalLight(nearestIntersection, intersectionModel);
    return light.multiply(intersectionModel.objectColor);
  }

  Point3D _reflect(Point3D vector, Point3D normal) {
    return vector - normal * 2 * vector.dot(normal);
  }

  Ray? _refract(
      Ray incidentRay, Intersection intersection, double refractiveIndex) {
    double ratio = intersection.inside ? refractiveIndex : 1 / refractiveIndex;
    final incident = incidentRay.direction.normalized();
    final normal =
        intersection.inside ? -intersection.normal : intersection.normal;

    double cosi = normal.dot(incident);
    double k = 1 - ratio * ratio * (1 - cosi * cosi);

    if (k < 0) return null;

    final refracted = incident * ratio - normal * (sqrt(k) + ratio * cosi);
    return Ray(
        start: intersection.hit + refracted * 0.001, direction: refracted);
  }

  Point3D _calcLocalLight(Intersection intersection, Model model) {
    Point3D color = Point3D.zero();
    for (var light in lights) {
      double illuminationRatio;
      Point3D lightDir = (intersection.hit - light.position).normalized();
      bool inShadow = false;
      for (var object in scene) {
        final shadowRay = Ray(
            start: intersection.hit - lightDir * 0.001, direction: -lightDir);
        final shadowIntersection = object.intersect(
            ray: shadowRay,
            view: _view,
            projection: _projection,
            camera: state.camera);
        if (shadowIntersection != null &&
            (intersection.hit - light.position).length() >
                (intersection.hit - shadowIntersection.hit).length()) {
          inShadow = true;
          break;
        }
      }
      if (!inShadow) {
        illuminationRatio = 1.0;
      } else {
        illuminationRatio = 0.15;
      }
      double diff = max(intersection.normal.dot(-lightDir), 0.0);
      color += light.color * diff * illuminationRatio;
    }
    color += ambientLight;
    return color..limitTop(1.0);
  }
}

List<Model> buildScene(List<Configuration> configurations) {
  return [
    // передняя
    Model(
      reflectivity: configurations[0].isMirror ? 0.85 : 0.0,
      transparency: configurations[0].isTransparent ? 0.95 : 0.0,
      color: Colors.white,
      points: [
        Point3D(2, 2, 0),
        Point3D(2, 0, 0),
        Point3D(0, 0, 0),
        Point3D(0, 2, 0)
      ],
      polygonsByIndexes: [
        [0, 1, 2],
        [2, 3, 0]
      ],
    ),
    // левая
    Model(
      reflectivity: configurations[1].isMirror ? 0.85 : 0.0,
      transparency: configurations[1].isTransparent ? 0.95 : 0.0,
      color: Colors.red,
      points: [
        Point3D(0, 2, 0),
        Point3D(0, 0, 0),
        Point3D(0, 0, 5),
        Point3D(0, 2, 5)
      ],
      polygonsByIndexes: [
        [0, 1, 2],
        [2, 3, 0]
      ],
    ),
    // правая
    Model(
      reflectivity: configurations[2].isMirror ? 0.85 : 0.0,
      transparency: configurations[2].isTransparent ? 0.95 : 0.0,
      color: Colors.blue,
      points: [
        Point3D(2, 0, 0),
        Point3D(2, 2, 0),
        Point3D(2, 0, 5),
        Point3D(2, 2, 5)
      ],
      polygonsByIndexes: [
        [0, 1, 2],
        [2, 1, 3]
      ],
    ),
    // верхняя
    Model(
      reflectivity: configurations[3].isMirror ? 0.85 : 0.0,
      transparency: configurations[3].isTransparent ? 0.95 : 0.0,
      color: Colors.white,
      points: [
        Point3D(2, 2, 0),
        Point3D(0, 2, 5),
        Point3D(2, 2, 5),
        Point3D(0, 2, 0)
      ],
      polygonsByIndexes: [
        [0, 1, 2],
        [0, 3, 1]
      ],
    ),
    // нижняя
    Model(
      reflectivity: configurations[4].isMirror ? 0.85 : 0.0,
      transparency: configurations[4].isTransparent ? 0.95 : 0.0,
      color: Colors.white,
      points: [
        Point3D(0, 0, 0),
        Point3D(2, 0, 0),
        Point3D(0, 0, 5),
        Point3D(2, 0, 5)
      ],
      polygonsByIndexes: [
        [0, 1, 2],
        [1, 3, 2]
      ],
    ),

    Model.cube(
      color: Colors.orange,
      reflectivity: configurations[5].isMirror ? 0.85 : 0.0,
      transparency: configurations[5].isTransparent ? 0.95 : 0.0,
    )
        .getTransformed(Matrix.scaling(Point3D(0.5, 0.5, 0.5)))
        .getTransformed(Matrix.rotation(vm.radians(-20), Point3D(0, 1, 0)))
        .getTransformed(Matrix.translation(Point3D(1.5, 0, 4))),
    Model.cube(
      color: Colors.pink,
      reflectivity: configurations[6].isMirror ? 0.85 : 0.0,
      transparency: configurations[6].isTransparent ? 0.95 : 0.0,
    )
        .getTransformed(Matrix.scaling(Point3D(0.3, 0.3, 0.3)))
        .getTransformed(Matrix.rotation(vm.radians(15), Point3D(0, 1, 0)))
        .getTransformed(Matrix.translation(Point3D(0.5, 0, 1))),
    Sphere.create(
      reflectivity: configurations[7].isMirror ? 0.85 : 0.0,
      transparency: configurations[7].isTransparent ? 0.95 : 0.0,
      color: Colors.green,
      radius: 0.5,
      center: Point3D(1.4, 0.5, 1),
    ),
    Sphere.create(
      reflectivity: configurations[8].isMirror ? 0.85 : 0.0,
      transparency: configurations[8].isTransparent ? 0.95 : 0.0,
      color: Colors.brown,
      radius: 0.3,
      center: Point3D(0.6, 0.3, 3),
    ),
  ];
}

Model buildLinesModel(scene) {
  var model = Model(points: [], polygonsByIndexes: [], color: Colors.black);
  for (var m in scene) {
    model = model.concat(m);
  }
  return model;
}
