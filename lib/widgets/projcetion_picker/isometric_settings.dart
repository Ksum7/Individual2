part of 'projection_picker.dart';

class _IsometricSettings extends StatefulWidget {
  const _IsometricSettings({Key? key, required this.onChanged}) : super(key: key);
  final Function(Matrix) onChanged;
  @override
  State<_IsometricSettings> createState() => _IsometricSettingsState();
}

class _IsometricSettingsState extends State<_IsometricSettings> {
  bool xAnglePos = true, yAnglePos = false;

  @override
  void initState() {
    super.initState();
    widget.onChanged(Matrix.isometric(xAnglePos, yAnglePos));
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
                    widget.onChanged(Matrix.isometric(xAnglePos, yAnglePos));
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
                    widget.onChanged(Matrix.isometric(xAnglePos, yAnglePos));
                  }
                }
            ),
            const Text("Угол для Y > 0?"),
          ],
        )
      ],
    );
  }
}