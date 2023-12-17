import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/painters/lines_painter.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/painters/ray_painter.dart';
import 'package:graphics_lab6/widgets/toolbar.dart';

import 'models/matrix.dart';
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
  bool _isFocused = false;
  FocusNode fNode = FocusNode();

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
                const SizedBox(width: 300, child: ToolBar()),
                Expanded(
                  child: RepaintBoundary(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            if (state is MoveState) {
                              context.read<MainBloc>().add(CameraScaleEvent(
                                  pointerSignal.scrollDelta.dy));
                            }
                          }
                        },
                        child: Focus(
                          canRequestFocus: true,
                          focusNode: fNode,
                          autofocus: true,
                          onKey: (node, event) {
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
                          child: MouseRegion(
                            cursor: _isFocused
                                ? SystemMouseCursors.none
                                : MouseCursor.defer,
                            child: GestureDetector(
                              onTap: () {
                                fNode.requestFocus();
                                final RenderBox renderBox = canvasAreaKey
                                    .currentContext!
                                    .findRenderObject() as RenderBox;
                                final centerPosition =
                                    renderBox.size.center(Offset.zero);
                                SystemChannels.mouseCursor.invokeMethod(
                                  'SystemMouseCursor.setPos',
                                  <double>[
                                    centerPosition.dx,
                                    centerPosition.dy
                                  ],
                                );
                                setState(() {
                                  //_isFocused = !_isFocused;
                                });
                              },
                              onPanDown: (details) {
                                fNode.requestFocus();
                                _previousPosition = details.localPosition;
                              },
                              onPanEnd: (details) {
                                _previousPosition = null;
                              },
                              onPanUpdate: (details) {
                                context.read<MainBloc>().add(
                                    CameraRotationEvent(details.localPosition -
                                        _previousPosition!));
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
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
