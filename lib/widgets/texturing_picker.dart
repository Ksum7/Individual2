import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';

class TexturingPicker extends StatefulWidget {
  const TexturingPicker({Key? key}) : super(key: key);

  @override
  State<TexturingPicker> createState() => _TexturingState();
}

class _TexturingState extends State<TexturingPicker> {
  String filename = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () {
            BlocProvider.of<MainBloc>(context).add(const LoadTextureEvent());
          },
          child: const Text(
            "Загрузить текстуру",
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        OutlinedButton(
          onPressed: () {
            BlocProvider.of<MainBloc>(context).add(const DeleteTextureEvent());
          },
          child: const Text(
            "Удалить текстуру",
          ),
        ),
        // SizedBox(
        //   child: Text(filename),
        // )
      ],
    );
  }
}
