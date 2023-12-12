part of 'projection_picker.dart';

class _Perspective3Settings extends StatefulWidget {
  const _Perspective3Settings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix?) onChanged;
  @override
  State<_Perspective3Settings> createState() => _Perspective3SettingsState();
}

class _Perspective3SettingsState extends State<_Perspective3Settings> {
  final xCenterController = TextEditingController(text: "10"), yCenterController = TextEditingController(text: "10"), zCenterController = TextEditingController(text: "-10");

  @override
  void initState() {
    super.initState();
    widget.onChanged(_getMatrix());
  }

  Matrix? _getMatrix(){
    final xCenter = double.tryParse(xCenterController.text);
    final yCenter = double.tryParse(yCenterController.text);
    final zCenter = double.tryParse(zCenterController.text);
    if (xCenter == null || yCenter == null || zCenter == null){
      return null;
    }
    return Matrix.perspective3(xCenter, yCenter, zCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Точка схода на X"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: xCenterController,
                onChanged: (_){
                  widget.onChanged(_getMatrix());
                },
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Точка схода на Y"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: yCenterController,
                onChanged: (_){
                  widget.onChanged(_getMatrix());
                },
              ),
            )
          ],
        ),
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
        )
      ],
    );
  }
}
