import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';

class MirroringPicker extends StatefulWidget {
  const MirroringPicker({Key? key}) : super(key: key);

  @override
  State<MirroringPicker> createState() => _TranslationState();
}

enum Planes {
  xy,
  xz,
  yz
}

class _TranslationState extends State<MirroringPicker> {

  @override
  void dispose() {
    super.dispose();
  }

  Planes _plane = Planes.xy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       RadioListTile<Planes>(
          title: const Text("XY"),
          value: Planes.xy,
          groupValue: _plane,
          onChanged: (Planes? value) {
            if (value != null) {
              setState(() {
                _plane = value;
              });
            }
          },
        ),

        RadioListTile<Planes>(
          title: const Text("YZ"),
          value: Planes.yz,
          groupValue: _plane,
          onChanged: (Planes? value) {
            if (value != null) {
              setState(() {
                _plane = value;
              });
            }
          },
        ),

        RadioListTile<Planes>(
          title: const Text("XZ"),
          value: Planes.xz,
          groupValue: _plane,
          onChanged: (Planes? value) {
            if (value != null) {
              setState(() {
                _plane = value;
              });
            }
          },
        ),

        ElevatedButton(
            onPressed: () {
              context.read<MainBloc>().add(MirrorPolyhedron(_plane));
            },
            child: const Text("Применить")
        )
      ],
    );
  }
}
