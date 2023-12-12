import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphics_lab6/bloc/main_bloc.dart';
import 'package:graphics_lab6/models/matrix.dart';
import 'package:graphics_lab6/models/projection_type.dart';
import 'package:graphics_lab6/widgets/snack_bar.dart';
import 'package:vector_math/vector_math.dart';

part 'isometric_settings.dart';
part 'dimetric_settings.dart';
part 'trimetric_settings.dart';
part 'perspective1_settings.dart';
part 'perspective2_settings.dart';
part 'perspective3_settings.dart';

class ProjectionPicker extends StatefulWidget {
  const ProjectionPicker({Key? key}) : super(key: key);

  @override
  State<ProjectionPicker> createState() => _ProjectionPickerState();
}

class _ProjectionPickerState extends State<ProjectionPicker> {
  ProjectionType _projectionType = ProjectionType.isometric;
  Matrix? _trimetricMatrix, _dimetricMatrix, _isometricMatrix, _perspective1Matrix, _perspective2Matrix, _perspective3Matrix;

  @override
  void initState() {
    super.initState();
    // context.read<MainBloc>().add(UpdateCamera(Matrix.isometric(true, false)));
  }

  void _updateType(ProjectionType? projectionType){
    if(projectionType != null){
      setState(() {
        _projectionType = projectionType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Аксонометрические", style: TextStyle(fontWeight: FontWeight.bold),),
        Row(
          children: [
            Radio(
                value: ProjectionType.isometric,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Изометрическая"),
          ],
        ),
        _IsometricSettings(
          onChanged: (newMatrix){
            _isometricMatrix = newMatrix;
          },
        ),
        Row(
          children: [
            Radio(
                value: ProjectionType.dimetric,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Диметрическая"),
          ],
        ),
        _DimetricSettings(
          onChanged: (newMatrix){
            _dimetricMatrix = newMatrix;
          },
        ),
        Row(
          children: [
            Radio(
                value: ProjectionType.trimetric,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Триметрическая"),
          ],
        ),
        _TrimetricSettings(
          onChanged: (newMatrix){
            _trimetricMatrix = newMatrix;
          },
        ),
        const Text("Перпективные", style: TextStyle(fontWeight: FontWeight.bold),),
        Row(
          children: [
            Radio(
                value: ProjectionType.perspective1,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Однототчечная"),
          ],
        ),
        _Perspective1Settings(
          onChanged: (newMatrix){
            _perspective1Matrix = newMatrix;
          },
        ),
        Row(
          children: [
            Radio(
                value: ProjectionType.perspective2,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Двухточечная"),
          ],
        ),
        _Perspective2Settings(
          onChanged: (newMatrix){
            _perspective2Matrix = newMatrix;
          },
        ),
        Row(
          children: [
            Radio(
                value: ProjectionType.perspective3,
                groupValue: _projectionType,
                onChanged: _updateType
            ),
            const SizedBox(width: 10,),
            Text("Трехточечная"),
          ],
        ),
        _Perspective3Settings(
          onChanged: (newMatrix){
            _perspective3Matrix = newMatrix;
          },
        ),
        const SizedBox(height: 20,),
        ElevatedButton(
          onPressed: (){
            final pickedProjectionMatrix = switch(_projectionType){
              ProjectionType.trimetric => _trimetricMatrix,
              ProjectionType.dimetric => _dimetricMatrix,
              ProjectionType.isometric => _isometricMatrix,
              ProjectionType.perspective1 => _perspective1Matrix,
              ProjectionType.perspective2 => _perspective2Matrix,
              ProjectionType.perspective3 => _perspective3Matrix,
            };
            if (pickedProjectionMatrix != null){
              // context.read<MainBloc>().add(UpdateCamera(pickedProjectionMatrix));
            } else{
              showAppSnackBar(context, "Одно или несколько полей заполнены неверно");
            }
          },
          child: Text("Применить")
        )
      ],
    );
  }
}
