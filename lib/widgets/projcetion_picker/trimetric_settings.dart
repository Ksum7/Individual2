part of 'projection_picker.dart';

class _TrimetricSettings extends StatefulWidget {
  const _TrimetricSettings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix?) onChanged;
  @override
  State<_TrimetricSettings> createState() => _TrimetricSettingsState();
}

class _TrimetricSettingsState extends State<_TrimetricSettings> {
  final xAngleController = TextEditingController(text: "30"), yAngleController = TextEditingController(text: "-30");

  @override
  void initState() {
    super.initState();
    widget.onChanged(_getMatrix());
  }

  Matrix? _getMatrix(){
    final xAngle = double.tryParse(xAngleController.text);
    final yAngle = double.tryParse(yAngleController.text);
    if (xAngle == null || yAngle == null){
      return null;
    }
    return Matrix.trimetric(radians(xAngle), radians(yAngle));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Угол вращения вокруг X"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: xAngleController,
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
            const Text("Угол вращения вокруг Y"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: yAngleController,
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
