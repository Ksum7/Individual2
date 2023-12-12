import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/disco_model.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:graphics_lab6/widgets/snack_bar.dart';

class RotationPicker extends StatefulWidget {
  const RotationPicker({Key? key}) : super(key: key);

  @override
  State<RotationPicker> createState() => _RotationPickerState();
}

enum _RotationLineType {centerXParallel, centerYParallel, centerZParallel, custom}

class _RotationPickerState extends State<RotationPicker> {
  final _angleController = TextEditingController(text: "0");
  final _x1Controller = TextEditingController(text: '0'),
      _y1Controller = TextEditingController(text: '0'),
      _z1Controller = TextEditingController(text: '0'),
      _x2Controller = TextEditingController(text: '1'),
      _y2Controller = TextEditingController(text: '0'),
      _z2Controller = TextEditingController(text: '0');
  _RotationLineType _rotationLineType = _RotationLineType.centerXParallel;
  late Timer _timer;
  bool _isAnimationRunning = false;

  void _pauseAnimation(){
    setState(() {
      _isAnimationRunning = false;
    });
    context.read<DiscoModel>().isEnabled = false;
    _timer.cancel();
  }

  void _runAnimation(){
    setState(() {
      _isAnimationRunning = true;
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: 5),
          (timer) {
        final center = context.read<MainBloc>().state.model.center;
        // context.read<MainBloc>().add(RotatePolyhedron(Edge(center, center + Point3D(1, 0 ,0)), 1));
        if (timer.tick % 2 == 0) {
          context.read<MainBloc>().add(RotatePolyhedron(Edge(center, center + Point3D(0, 1 ,0)), 1));
        }
        // if (timer.tick % 3 == 0) {
        //   context.read<MainBloc>().add(RotatePolyhedron(Edge(center, center + Point3D(0, 0 ,1)), 1));
        // }
      },
    );
  }

  void _updateType(_RotationLineType? rotationLineType){
    if(rotationLineType != null){
      setState(() {
        _rotationLineType = rotationLineType;
      });
    }
  }

  Edge? _getLine() {
    final center = context.read<MainBloc>().state.model.center;
    late final Edge? customEdge;
    if (_rotationLineType == _RotationLineType.custom){
      final x1 = double.tryParse(_x1Controller.text),
          y1 = double.tryParse(_y1Controller.text),
          z1 = double.tryParse(_z1Controller.text),
          x2 = double.tryParse(_x2Controller.text),
          y2 = double.tryParse(_y2Controller.text),
          z2 = double.tryParse(_z2Controller.text);
      if (x1 == null || y1 == null || z1 == null || x2 == null || y2 == null || z2 == null){
        customEdge = null;
      } else {
        customEdge = Edge(Point3D(x1, y1, z1), Point3D(x2, y2, z2));
      }
    }
    return switch(_rotationLineType){
      _RotationLineType.centerXParallel => Edge(center, center + Point3D(1, 0 ,0)),
      _RotationLineType.centerYParallel => Edge(center, center + Point3D(0, 1 ,0)),
      _RotationLineType.centerZParallel => Edge(center, center + Point3D(0, 0 ,1)),
      _RotationLineType.custom => customEdge,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _isAnimationRunning ?
                _pauseAnimation : _runAnimation,
              icon: Icon(_isAnimationRunning ?
                Icons.pause_circle_outline : Icons.play_circle_outline)
            ),
            Checkbox(
              value: context.read<DiscoModel>().isEnabled,
              onChanged: (value) {
                if (_isAnimationRunning && value != null){
                  setState(() {
                    context.read<DiscoModel>().isEnabled = value;
                  });
                }
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Угол"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: _angleController,
              ),
            )
          ],
        ),
        const SizedBox(height: 10,),
        const Text("Прямая"),
        Row(
          children: [
            Radio(
              value: _RotationLineType.centerXParallel,
              groupValue: _rotationLineType,
              onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            const Text("Через центр, || оси X"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: _RotationLineType.centerYParallel,
              groupValue: _rotationLineType,
              onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            const Text("Через центр, || оси Y"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: _RotationLineType.centerZParallel,
              groupValue: _rotationLineType,
              onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            const Text("Через центр, || оси Z"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: _RotationLineType.custom,
              groupValue: _rotationLineType,
              onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            const Text("Произвольная"),
          ],
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "X1"
                  ),
                  controller: _x1Controller,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Y1"
                  ),
                  controller: _y1Controller,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Z1"
                  ),
                  controller: _z1Controller,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "X2"
                  ),
                  controller: _x2Controller,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Y2"
                  ),
                  controller: _y2Controller,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Z2"
                  ),
                  controller: _z2Controller,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20,),
        ElevatedButton(
          onPressed: () {
            final line = _getLine();
            final angle = double.tryParse(_angleController.text);
            if (line == null) {
              showAppSnackBar(context, "Точки введены в неверном формате");
              return;
            }
            if (angle == null) {
              showAppSnackBar(context, "Угол введен в неверном формате");
              return;
            }
            context.read<MainBloc>().add(RotatePolyhedron(line, angle));
          },
          child: const Text("Применить")
        ),
      ],
    );
  }
}
