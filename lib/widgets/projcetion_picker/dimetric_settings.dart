part of 'projection_picker.dart';


class _DimetricSettings extends StatefulWidget {
  const _DimetricSettings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix?) onChanged;
  @override
  State<_DimetricSettings> createState() => _DimetricSettingsState();
}

class _DimetricSettingsState extends State<_DimetricSettings> {
  bool xAnglePos = true, yAnglePos = false;
  final zRatioController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    widget.onChanged(_getMatrix());
  }

  Matrix? _getMatrix(){
    final zRatio = double.tryParse(zRatioController.text);
    if (zRatio == null || zRatio < 0 || zRatio > 1) {
      return null;
    }
    return Matrix.dimetric(zRatio, xAnglePos, yAnglePos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: xAnglePos,
              onChanged: (value){
                if (value != null){
                  setState(() {
                    xAnglePos = value;
                  });
                  widget.onChanged(_getMatrix());
                }
              }
            ),
            const Text("Угол для X > 0?"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: yAnglePos,
              onChanged: (value){
                if (value != null){
                  setState(() {
                    yAnglePos = value;
                  });
                  widget.onChanged(_getMatrix());
                }
              }
            ),
            const Text("Угол для Y > 0?"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Коэффициент искажения Z"),
            const SizedBox(width: 10,),
            SizedBox(
              height: 40,
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller: zRatioController,
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