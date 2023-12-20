part of 'main_bloc.dart';

@immutable
sealed class MainState {
  final Camera camera;
  const MainState({
    required this.camera,
  });
}

class MoveState extends MainState {
  final Model model;
  final String? message;
  const MoveState({required this.model, required super.camera, this.message});

  MoveState copyWith({
    Model? model,
    Camera? camera,
    String? message,
    bool? lightMode,
  }) =>
      MoveState(
          model: model ?? this.model,
          camera: camera ?? this.camera,
          message: message);
}

class DrawState extends MainState {
  final List<List<({Color color, Offset pos})?>> pixels;
  const DrawState({
    required this.pixels,
    required super.camera,
  });

  DrawState copyWith({
    List<List<({Color color, Offset pos})?>>? pixels,
    Camera? camera,
  }) =>
      DrawState(
        camera: camera ?? this.camera,
        pixels: pixels ?? this.pixels,
      );
}
