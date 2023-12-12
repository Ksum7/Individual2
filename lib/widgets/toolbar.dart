import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/widgets/camera_picker.dart';
import 'package:graphics_lab6/widgets/hiding_panel.dart';
import 'package:graphics_lab6/widgets/model_picker/model_picker.dart';
import 'package:graphics_lab6/widgets/projcetion_picker/projection_picker.dart';
import 'package:graphics_lab6/widgets/rotation_picker.dart';
import 'package:graphics_lab6/widgets/scaling_picker.dart';
import 'package:graphics_lab6/widgets/shading_picker.dart';
import 'package:graphics_lab6/widgets/texturing_picker.dart';
import 'package:graphics_lab6/widgets/translation_picker.dart';

import 'mirroring_picker.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            const HidingPanel(
                title: Text("Настройки камеры"), child: CameraPicker()),
            const HidingPanel(title: Text("Модель"), child: ModelPicker()),
            const HidingPanel(title: Text("Вращение"), child: RotationPicker()),
            const HidingPanel(
              title: Text("Перемещение"),
              child: TranslationPicker(),
            ),
            const HidingPanel(
              title: Text("Масштабирование"),
              child: ScalingPicker(),
            ),
            const HidingPanel(
              title: Text("Отражение"),
              child: MirroringPicker(),
            ),
            const HidingPanel(
              title: Text("Текстурирование"),
              child: TexturingPicker(),
            ),
            const HidingPanel(
              title: Text("Освещение"),
              child: ShadingPicker(),
            ),
            const SizedBox(
              height: 15,
            ),
            OutlinedButton(
              onPressed: () {
                BlocProvider.of<MainBloc>(context).add(const SaveObjEvent());
              },
              child: const Text(
                "Сохранить",
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            OutlinedButton(
              onPressed: () {
                BlocProvider.of<MainBloc>(context).add(const LoadObjEvent());
              },
              child: const Text(
                "Загрузить",
              ),
            ),
          ],
        ));
  }
}
