import 'package:flutter/material.dart';

class BinaryOperatorButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Function? onLongPressed;

  const BinaryOperatorButton(
      {Key? key,
      required this.onPressed,
      this.onLongPressed,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          constraints: BoxConstraints.tight(const Size(60.0, 60.0)),
          onPressed: onPressed as void Function()?,
          onLongPress:
              onLongPressed == null ? null : onLongPressed as void Function()?,
          fillColor: Colors.orange,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ));
  }
}
