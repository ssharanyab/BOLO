import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton(
      {Key key, this.onPressed, style, Ink child, this.text})
      : super(key: key);
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Ink(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF1BA9CC), Color(0xFF2BCECA)]),
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static styleFrom({EdgeInsets padding, RoundedRectangleBorder shape}) {}
}
