part of 'main_bloc.dart';

@immutable
sealed class MainState {
  const MainState();
}

class MoveState extends MainState {
  final Model model;
  final Camera camera;
  final String? message;
  const MoveState({required this.model, required this.camera, this.message});

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
  });

  DrawState copyWith({
    List<List<({Color color, Offset pos})?>>? pixels,
  }) =>
      DrawState(
        pixels: pixels ?? this.pixels,
      );
}
