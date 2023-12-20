import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/painters/lines_painter.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/painters/ray_painter.dart';
import 'package:graphics_lab6/widgets/camera_picker.dart';
import 'package:graphics_lab6/widgets/hiding_panel.dart';

import 'models/primitives.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => MainBloc(),
        child: MainPage(),
      ),
    );
  }
}

final canvasAreaKey = GlobalKey();

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Offset? _previousPosition;
  bool _isLines = true;
  FocusNode fNode = FocusNode();
  List<Configuration> configurations = [
    Configuration(name: "Стена передняя"),
    Configuration(name: "Стена левая"),
    Configuration(name: "Стена правая"),
    Configuration(name: "Стена верхняя"),
    Configuration(name: "Стена нижняя"),
    Configuration(name: "Куб большой"),
    Configuration(name: "Куб маленький"),
    Configuration(name: "Сфера большая"),
    Configuration(name: "Сфера маленькая"),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: BlocConsumer<MainBloc, MainState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 300,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: Column(
                        children: [
                          const HidingPanel(
                              title: Text("Настройки камеры"),
                              child: CameraPicker()),
                          const SizedBox(
                            height: 15,
                          ),
                          ...List.generate(
                            configurations.length,
                            (index) => Column(
                              children: [
                                Text(configurations[index].name),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Активность'),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Checkbox(
                                        value: configurations[index].isVisible,
                                        onChanged: !_isLines
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    configurations[index]
                                                        .isVisible = value;
                                                  });
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Прозрачность'),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Checkbox(
                                        value:
                                            configurations[index].isTransparent,
                                        onChanged: !_isLines
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    configurations[index]
                                                        .isTransparent = value;
                                                  });
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Зеркальность'),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Checkbox(
                                        value: configurations[index].isMirror,
                                        onChanged: !_isLines
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    configurations[index]
                                                        .isMirror = value;
                                                  });
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLines = !_isLines;
                                  });

                                  context.read<MainBloc>().add(SwitchModeEvent(
                                      _isLines, configurations));
                                },
                                child: const Text('Переключить режим')),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  child: RepaintBoundary(
                    child: LayoutBuilder(builder: (context, constraints) {
                      context.read<MainBloc>().width =
                          constraints.maxWidth.toInt();
                      context.read<MainBloc>().height =
                          constraints.maxHeight.toInt();
                      return Listener(
                        onPointerSignal: (pointerSignal) {
                          // if (_isLines && pointerSignal is PointerScrollEvent) {
                          //   if (state is MoveState) {
                          //     context.read<MainBloc>().add(CameraScaleEvent(
                          //         pointerSignal.scrollDelta.dy));
                          //   }
                          // }
                        },
                        child: Focus(
                          canRequestFocus: true,
                          focusNode: fNode,
                          autofocus: true,
                          onKey: (node, event) {
                            if (!_isLines) return KeyEventResult.handled;

                            double speed = 0.1;
                            switch (event.logicalKey) {
                              case LogicalKeyboardKey.keyA:
                                context.read<MainBloc>().add(
                                    CameraMoveEvent(Point3D(-speed, 0, 0)));
                                break;
                              case LogicalKeyboardKey.keyD:
                                context
                                    .read<MainBloc>()
                                    .add(CameraMoveEvent(Point3D(speed, 0, 0)));
                                break;
                              case LogicalKeyboardKey.keyW:
                                context.read<MainBloc>().add(
                                    CameraMoveEvent(Point3D(0, 0, speed * 2)));
                                break;
                              case LogicalKeyboardKey.keyS:
                                context.read<MainBloc>().add(
                                    CameraMoveEvent(Point3D(0, 0, -speed * 2)));
                                break;
                              case LogicalKeyboardKey.shiftLeft:
                              case LogicalKeyboardKey.space:
                                context
                                    .read<MainBloc>()
                                    .add(CameraMoveEvent(Point3D(0, speed, 0)));
                                break;
                              case LogicalKeyboardKey.controlLeft:
                                context.read<MainBloc>().add(
                                    CameraMoveEvent(Point3D(0, -speed, 0)));
                                break;
                              default:
                            }

                            return KeyEventResult.handled;
                          },
                          child: GestureDetector(
                            onTap: !_isLines
                                ? null
                                : () {
                                    fNode.requestFocus();
                                  },
                            onPanDown: !_isLines
                                ? null
                                : (details) {
                                    fNode.requestFocus();
                                    _previousPosition = details.localPosition;
                                  },
                            onPanEnd: !_isLines
                                ? null
                                : (details) {
                                    _previousPosition = null;
                                  },
                            onPanUpdate: !_isLines
                                ? null
                                : (details) {
                                    context.read<MainBloc>().add(
                                        CameraRotationEvent(
                                            (details.localPosition -
                                                _previousPosition!)));
                                    _previousPosition = details.localPosition;
                                  },
                            child: ClipRRect(
                              key: canvasAreaKey,
                              child: CustomPaint(
                                foregroundPainter: switch (state) {
                                  DrawState() =>
                                    RayPainter(pixels: state.pixels),
                                  MoveState() => LinesPainter(
                                      camera: state.camera,
                                      polyhedron: state.model,
                                    ),
                                },
                                child: Container(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Configuration {
  final String name;
  bool isVisible;
  bool isMirror;
  bool isTransparent;
  Configuration(
      {required this.name,
      this.isVisible = true,
      this.isMirror = false,
      this.isTransparent = false});
}
