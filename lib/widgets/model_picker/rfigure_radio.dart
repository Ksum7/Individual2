
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';

class RFigureRadio extends StatefulWidget {
  const RFigureRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onRadioUpdate,
  }) : super(key: key);
  final int groupValue;
  final int value;
  final Function(int?) onRadioUpdate;

  @override
  State<RFigureRadio> createState() => _RFigureRadioState();
}

class _RFigureRadioState extends State<RFigureRadio> {
  final _vectorController = TextEditingController(text: '0 1 0');
  final _divisionsController = TextEditingController(text: '50');

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state is CurveReadyState){
          context.read<MainBloc>().add(PickRFigure(state.points, _vectorController.text, _divisionsController.text));
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: widget.value,
                groupValue: widget.groupValue,
                onChanged: (value) {
                  if (widget.value == value) {
                    context.read<MainBloc>().add(const CurvePanEvent(null));
                  }
                  widget.onRadioUpdate(value);
                },
              ),
              const Text("Фигура вращения"),
            ],
          ),
          // ElevatedButton(onPressed: () {}, child: const Text("Применить")),
          SizedBox(
            height: 65,
            width: 220,
            child: TextField(
              controller: _vectorController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero, label: Text('Ось вращения')),
            ),
          ),
          SizedBox(
            height: 65,
            width: 220,
            child: TextField(
              controller: _divisionsController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  label: Text('Количество разбиений')),
            ),
          ),
        ],
      ),
    );
  }
}
