import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/polyhedron_type.dart';
import 'package:graphics_lab6/widgets/model_picker/function_radio.dart';
import 'package:graphics_lab6/widgets/model_picker/rfigure_radio.dart';

class ModelPicker extends StatefulWidget {
  const ModelPicker({Key? key}) : super(key: key);

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    context.read<MainBloc>().add(const PickPolyhedron(PolyhedronType.cube));
  }

  void _updateRadioIndex(int? newIndex) {
    if (newIndex == null) {
      return;
    }
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _pickPolyhedron(int? newIndex) {
    _updateRadioIndex(newIndex);
    final event = switch (_currentIndex) {
      0 => const PickPolyhedron(PolyhedronType.tetrahedron),
      1 => const PickPolyhedron(PolyhedronType.cube),
      2 => const PickPolyhedron(PolyhedronType.octahedron),
      3 => const PickPolyhedron(PolyhedronType.icosahedron),
      4 => const PickPolyhedron(PolyhedronType.dodecahedron),
      _ => null
    };
    if (event != null) {
      context.read<MainBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Radio(
              value: 0,
              groupValue: _currentIndex,
              onChanged: _pickPolyhedron,
            ),
            const Text("Тетраэдр"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: 1,
              groupValue: _currentIndex,
              onChanged: _pickPolyhedron,
            ),
            const Text("Куб"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: 2,
              groupValue: _currentIndex,
              onChanged: _pickPolyhedron,
            ),
            const Text("Октаэдр"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: 3,
              groupValue: _currentIndex,
              onChanged: _pickPolyhedron,
            ),
            const Text("Икосаэдр"),
          ],
        ),
        Row(
          children: [
            Radio(
              value: 4,
              groupValue: _currentIndex,
              onChanged: _pickPolyhedron,
            ),
            const Text("Додекаэдр"),
          ],
        ),
        FunctionRadio(
            value: 5,
            groupValue: _currentIndex,
            onRadioUpdate: _updateRadioIndex),
        RFigureRadio(
            value: 6,
            groupValue: _currentIndex,
            onRadioUpdate: _updateRadioIndex),
      ],
    );
  }
}
