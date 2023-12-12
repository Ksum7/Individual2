part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}

class PickPolyhedron extends MainEvent {
  final PolyhedronType polyhedronType;
  const PickPolyhedron(this.polyhedronType);
}

class UpdateCamera extends MainEvent {
  final Camera camera;
  const UpdateCamera(this.camera);
}

class UpdateLight extends MainEvent {
  final Light light;
  const UpdateLight(this.light);
}

class ToggleLight extends MainEvent {
  const ToggleLight();
}

class PickFunction extends MainEvent {
  final double Function(double, double) func;
  final String restrictions;
  const PickFunction(this.func, this.restrictions);
}

class PickRFigure extends MainEvent {
  final List<Point3D> points;
  final String vectorStr, divisionsStr;
  const PickRFigure(this.points, this.vectorStr, this.divisionsStr);
}

class RotatePolyhedron extends MainEvent {
  final Edge line;
  final double angle;
  const RotatePolyhedron(this.line, this.angle);
}

class TranslatePolyhedron extends MainEvent {
  final Point3D translation;
  const TranslatePolyhedron(this.translation);
}

class ScalePolyhedron extends MainEvent {
  final Point3D translation;
  const ScalePolyhedron(this.translation);
}

class MirrorPolyhedron extends MainEvent {
  final Planes plane;
  const MirrorPolyhedron(this.plane);
}

class CurvePanEvent extends MainEvent {
  final Offset? position;
  final Size? size;
  const CurvePanEvent(this.position, [this.size]);
}

class SaveObjEvent extends MainEvent {
  const SaveObjEvent();
}

class LoadObjEvent extends MainEvent {
  const LoadObjEvent();
}

class LoadTextureEvent extends MainEvent {
  const LoadTextureEvent();
}

class DeleteTextureEvent extends MainEvent {
  const DeleteTextureEvent();
}

class ShowMessageEvent extends MainEvent {
  final String message;
  const ShowMessageEvent(this.message);
}

class CameraRotationEvent extends MainEvent {
  final Offset delta;
  const CameraRotationEvent(this.delta);
}

class CameraScaleEvent extends MainEvent {
  final double delta;
  const CameraScaleEvent(this.delta);
}

class FloatingHorizonScaleEvent extends MainEvent {
  final double delta;
  const FloatingHorizonScaleEvent(this.delta);
}
