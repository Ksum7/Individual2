part of 'projection_picker.dart';

class _Perspective2Settings extends StatefulWidget {
  const _Perspective2Settings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix?) onChanged;
  @override
  State<_Perspective2Settings> createState() => _Perspective2SettingsState();
}

class _Perspective2SettingsState extends State<_Perspective2Settings> {
  final xCenterController = TextEditingController(text: "-10"), yCenterController = TextEditingController(text: "-10");

  @override
  void initState() {
    super.initState();
    widget.onChanged(_getMatrix());
  }

  Matrix? _getMatrix(){
    final xCenter = double.tryParse(xCenterController.text);
    final yCenter = double.tryParse(yCenterController.text);
    if (xCenter == null || yCenter == null){
      return null;
    }
    return Matrix.perspective2(xCenter, yCenter);
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
      ],
    );
  }
}
