import 'package:flutter/material.dart';

class ZeroButton extends StatelessWidget {
  const ZeroButton({Key? key, required this.onPressed}) : super(key: key);

  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 60.0,
        width: MediaQuery.of(context).size.width / 2.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: const Color.fromRGBO(56, 54, 56, 1.0)),
        child: MaterialButton(
          onPressed: onPressed as void Function()?,
          child: const Text(
            "0",
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
