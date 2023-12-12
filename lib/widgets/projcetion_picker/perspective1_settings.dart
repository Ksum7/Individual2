part of 'projection_picker.dart';

class _Perspective1Settings extends StatefulWidget {
  const _Perspective1Settings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix?) onChanged;
  @override
  State<_Perspective1Settings> createState() => _Perspective1SettingsState();
}

class _Perspective1SettingsState extends State<_Perspective1Settings> {
  final zCenterController = TextEditingController(text: "10");

  @override
  void initState() {
    super.initState();
    widget.onChanged(_getMatrix());
  }

  Matrix? _getMatrix(){
    final zCenter = double.tryParse(zCenterController.text);
    if (zCenter == null){
      return null;
    }
    return Matrix.perspective1(zCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Точка схода на Z"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: zCenterController,
                onChanged: (_){
                  widget.onChanged(_getMatrix());
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}
