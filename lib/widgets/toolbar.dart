import 'package:flutter/material.dart';
import 'package:graphics_lab6/widgets/camera_picker.dart';
import 'package:graphics_lab6/widgets/hiding_panel.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            HidingPanel(title: Text("Настройки камеры"), child: CameraPicker()),
            SizedBox(
              height: 15,
            ),
          ],
        ));
  }
}
