import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';

class FunctionRadio extends StatefulWidget {
  const FunctionRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onRadioUpdate,
  }) : super(key: key);
  final int groupValue;
  final int value;
  final Function(int?) onRadioUpdate;

  @override
  State<FunctionRadio> createState() => _FunctionRadioState();
}

class _FunctionRadioState extends State<FunctionRadio> {
  double _pulse(double x, double z){
    var r = x * x + z * z + 1;
    return 5 * (cos(r)/r + 0.1);
  }

  double _sqr(double x, double z){
    return x * x + z * z - 2;
  }

  double _trigonometry(double x, double z){
    return sin(x) * cos(z);
  }

  late double Function(double, double) _selectedFunction = _pulse;
  final _tController = TextEditingController(text: '-3 3 1e-1');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Radio(
              value: widget.value,
              groupValue: widget.groupValue,
              onChanged: (value) {
                if (widget.value == value){
                  context.read<MainBloc>().add(PickFunction(_selectedFunction, _tController.text));
                }
                widget.onRadioUpdate(value);
              },
            ),
            const Text("График функции"),
          ],
        ),
        SizedBox(
          height: 65,
          width: 220,
          child: DropdownButton<double Function(double, double)>(
            isExpanded: true,
            value: _selectedFunction,
            underline: Divider(color: Theme.of(context).primaryColor,),
            menuMaxHeight: 100,
            focusColor: Colors.transparent,
            items: [
              DropdownMenuItem(
                value: _pulse,
                child: const Text('r = x * x + z * z + 1\n5 * (Math.Cos(r) / r + 0.1)'),
              ),
              DropdownMenuItem(
                value: _sqr,
                child: const Text('x * x + z * z - 2'),
              ),
              DropdownMenuItem(
                value: _trigonometry,
                child: const Text('sin(x) * cos(z)'),
              ),
            ],
            onChanged: (value) {
              if (value == null){
                return;
              }
              setState(() {
                _selectedFunction = value;
              });
              if (widget.value == widget.groupValue){
                context.read<MainBloc>().add(PickFunction(_selectedFunction, _tController.text));
              }
            },
          ),
        ),
        SizedBox(
          height: 65,
          width: 220,
          child: TextField(
            controller: _tController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              label: Text('Min Max Step')
            ),
          ),
        )
      ],
    );
  }
}
