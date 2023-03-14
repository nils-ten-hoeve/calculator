import 'package:flutter/material.dart';

class UnaryOperatorButton extends StatelessWidget {
  const UnaryOperatorButton(
      {Key? key, required this.text, required this.onPressed})
      : super(key: key);

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          constraints: BoxConstraints.tight(const Size(60.0, 60.0)),
          onPressed: onPressed as void Function()?,
          fillColor: Colors.grey,
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 20.0),
          ),
        ));
  }
}
