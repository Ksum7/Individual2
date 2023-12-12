import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/primtives.dart';
import 'package:graphics_lab6/widgets/snack_bar.dart';

class ScalingPicker extends StatefulWidget {
  const ScalingPicker({Key? key}) : super(key: key);

  @override
  State<ScalingPicker> createState() => _TranslationState();
}

class _TranslationState extends State<ScalingPicker> {
  final _xController = TextEditingController(text: '0'),
      _yController = TextEditingController(text: '0'),
      _zController = TextEditingController(text: '0');

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "X"
                  ),
                  controller: _xController,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Y"
                  ),
                  controller: _yController,
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Z"
                  ),
                  controller: _zController,
                ),
              )
            ],
          ),
        ),

        ElevatedButton(
            onPressed: () {
              final x = double.tryParse(_xController.text);
              final y = double.tryParse(_yController.text);
              final z = double.tryParse(_zController.text);
              if (x == null || y == null || z == null) {
                showAppSnackBar(context, "Неверный формат ввода");
                return;
              }
              context.read<MainBloc>().add(ScalePolyhedron(Point3D(x,y,z)));
            },
            child: const Text("Применить")
        )
      ],
    );
  }
}
