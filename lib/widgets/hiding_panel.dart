import 'package:flutter/material.dart';

class HidingPanel extends StatefulWidget {
  const HidingPanel({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);
  final Widget child;
  final Widget title;

  @override
  State<HidingPanel> createState() => _HidingPanelState();
}

class _HidingPanelState extends State<HidingPanel> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.title,
            IconButton(
              onPressed: (){
                setState(() {
                  isHidden = !isHidden;
                });
              },
              icon: Icon(isHidden ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 25,)
            )
          ],
        ),
        Visibility(
          visible: isHidden,
          child: const Divider(),
        ),
        Visibility(
          maintainState: true,
          visible: !isHidden,
          child: widget.child,
        )
      ],
    );
  }
}
