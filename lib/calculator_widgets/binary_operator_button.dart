import 'package:flutter/material.dart';


class BinaryOperatorButton extends StatelessWidget {

  BinaryOperatorButton({required this.onPressed, this.onLongPressed, this.text});

  final text;
  final Function onPressed;
  final Function? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          constraints: BoxConstraints.tight(Size(60.0, 60.0)),
          onPressed:onPressed as void Function()?,
          onLongPress:onLongPressed==null?null: onLongPressed as void Function()?,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          fillColor: Colors.orange,
        ));
  }

}
