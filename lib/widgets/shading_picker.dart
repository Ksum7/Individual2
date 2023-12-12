import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/light.dart';
import 'package:graphics_lab6/models/primtives.dart';

class ShadingPicker extends StatefulWidget {
  const ShadingPicker({Key? key}) : super(key: key);

  @override
  State<ShadingPicker> createState() => _ShadingPickerState();
}

class _ShadingPickerState extends State<ShadingPicker> {
  final _posController = TextEditingController();
  final _directionController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final light = context.watch<MainBloc>().state.light;
    _posController.text =
        "${light.pos.x.toStringAsFixed(2)} ${light.pos.y.toStringAsFixed(2)} ${light.pos.z.toStringAsFixed(2)}";
    _directionController.text =
        "${light.direction.x.toStringAsFixed(2)} ${light.direction.y.toStringAsFixed(2)} ${light.direction.z.toStringAsFixed(2)}";
    _colorController.text =
        "${light.color.x.toStringAsFixed(0)} ${light.color.y.toStringAsFixed(2)} ${light.color.z.toStringAsFixed(2)}";
  }

  void _onApply() {
    final posList = _posController.text.split(' ');
    if (posList.length != 3) {
      context
          .read<MainBloc>()
          .add(const ShowMessageEvent('Неверно задана позиция света'));
      return;
    }
    final directionList = _directionController.text.split(' ');
    if (directionList.length != 3) {
      context
          .read<MainBloc>()
          .add(const ShowMessageEvent('Неверно задано направлние света'));
      return;
    }
    final colorList = _colorController.text.split(' ');
    if (colorList.length != 3) {
      context
          .read<MainBloc>()
          .add(const ShowMessageEvent('Неверно задан цвет'));
      return;
    }
    late final Point3D pos, direction, color;
    try {
      pos = Point3D(double.parse(posList[0]), double.parse(posList[1]),
          double.parse(posList[2]));
      direction = Point3D(double.parse(directionList[0]),
          double.parse(directionList[1]), double.parse(directionList[2]));
      color = Point3D(double.parse(colorList[0]), double.parse(colorList[1]),
          double.parse(colorList[2]));
    } catch (_) {
      context
          .read<MainBloc>()
          .add(const ShowMessageEvent('Неверно заданы точки'));
      return;
    }
    context.read<MainBloc>().add(
          UpdateLight(
            Light(
              pos: pos,
              direction: direction,
              color: color,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 65,
          width: 220,
          child: TextField(
            controller: _posController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Text('Положение света')),
          ),
        ),
        SizedBox(
          height: 65,
          width: 220,
          child: TextField(
            controller: _colorController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero, label: Text('Цвет фигуры')),
          ),
        ),
        ElevatedButton(
          onPressed: _onApply,
          child: const Text(
            "Применить",
          ),
        ),
        const SizedBox(height: 10,),
        BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () {
                context.read<MainBloc>().add(const ToggleLight());
              },
              child: Text(
                state.lightMode ? "Выключить" : "Включить",
              ),
            );
          },
        )
      ],
    );
  }
}
