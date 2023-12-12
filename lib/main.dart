import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/models/light.dart';
import 'package:graphics_lab6/painters/app_painter.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/disco_model.dart';
import 'package:graphics_lab6/painters/curve_painter.dart';
import 'package:graphics_lab6/painters/floating_horizon_painter.dart';
import 'package:graphics_lab6/widgets/toolbar.dart';

import 'models/matrix.dart';
import 'models/primtives.dart';

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
  final _discoModel = DiscoModel();
  Offset? _previousPosition;

  @override
  void dispose() async {
    await _discoModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: RepositoryProvider.value(
          value: _discoModel,
          child: BlocConsumer<MainBloc, MainState>(
            listener: (context, state) {
              if (state.message != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  width: 700,
                  content: Text(
                    state.message!,
                    textAlign: TextAlign.center,
                  ),
                ));
              }
            },
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 300, child: ToolBar()),
                  Expanded(
                    child: RepaintBoundary(
                      child: Stack(
                        children: [
                          LayoutBuilder(builder: (context, constraints) {
                            return Listener(
                              onPointerSignal: (pointerSignal) {
                                if (pointerSignal is PointerScrollEvent) {
                                  if (state is CommonState) {
                                    context.read<MainBloc>().add(
                                        CameraScaleEvent(
                                            pointerSignal.scrollDelta.dy));
                                  }
                                  if (state is FloatingHorizonState) {
                                    context.read<MainBloc>().add(
                                        FloatingHorizonScaleEvent(
                                            pointerSignal.scrollDelta.dy));
                                  }
                                }
                              },
                              child: GestureDetector(
                                onPanDown: state is CurveDrawingState
                                    ? (details) {
                                        context.read<MainBloc>().add(
                                            CurvePanEvent(
                                                details.localPosition));
                                      }
                                    : (details) {
                                        _previousPosition =
                                            details.localPosition;
                                      },
                                onPanEnd: state is CurveDrawingState
                                    ? (details) {
                                        context.read<MainBloc>().add(
                                            CurvePanEvent(
                                                null,
                                                Size(constraints.maxWidth,
                                                    constraints.maxHeight)));
                                      }
                                    : (details) {
                                        _previousPosition = null;
                                      },
                                onPanUpdate: state is CurveDrawingState
                                    ? (details) {
                                        context.read<MainBloc>().add(
                                            CurvePanEvent(
                                                details.localPosition));
                                      }
                                    : (details) {
                                        context.read<MainBloc>().add(
                                            CameraRotationEvent(
                                                details.localPosition -
                                                    _previousPosition!));
                                        _previousPosition =
                                            details.localPosition;
                                      },
                                child: ClipRRect(
                                  key: canvasAreaKey,
                                  child: CustomPaint(
                                    foregroundPainter: switch (state) {
                                      CurveDrawingState() =>
                                        CurvePainter(path: state.path),
                                      FloatingHorizonState() =>
                                        FloatingHorizonPainter(
                                            camera: state.camera,
                                            step: state.step,
                                            max: state.max,
                                            min: state.min,
                                            func: state.func,
                                            secretFeature: context
                                                .read<DiscoModel>()
                                                .isEnabled,
                                            pixelRatio: state.pixelRatio),
                                      _ => AppPainter(
                                          //light: Light(pos: state.camera.eye),
                                          light: state.light,
                                          lightMode: state.lightMode,
                                          camera: state.camera,
                                          polyhedron: state.model.concat(
                                            Model.tetrahedron.getTransformed(
                                              Matrix.translation(
                                                state.light.pos,
                                              ),
                                            ),
                                          ),
                                          secretFeature: context
                                              .read<DiscoModel>()
                                              .isEnabled,
                                        ),
                                    },
                                    child: Container(
                                      color: context
                                              .watch<DiscoModel>()
                                              .isEnabled
                                          ? context.watch<DiscoModel>().color
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Visibility(
                              visible: context.read<DiscoModel>().isEnabled,
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2 -
                                          100,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      200,
                                  child: Image.asset(
                                    'assets/gifs/dance.gif',
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Visibility(
                              visible: context.read<DiscoModel>().isEnabled,
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2 -
                                          100,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      200,
                                  child: Image.asset(
                                    'assets/gifs/spongebob.gif',
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Visibility(
                              visible: context.read<DiscoModel>().isEnabled,
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2 -
                                          100,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      200,
                                  child: Image.asset(
                                    'assets/gifs/patrick.gif',
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Visibility(
                              visible: context.read<DiscoModel>().isEnabled,
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2 -
                                          100,
                                  width: MediaQuery.of(context).size.width / 2 -
                                      200,
                                  child: Image.asset(
                                    'assets/gifs/lizard.gif',
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
