import 'package:flutter/material.dart';

ElevatedButton customElevatedButton(String text, Function func) {
  return ElevatedButton(
    onPressed: func,
    style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
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

Column buildButtonColumn(Color color, Color splashColor, IconData icon,
    String label, Function func) {
  return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(icon),
            color: color,
            splashColor: splashColor,
            onPressed: () => func()),
        Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.0, fontWeight: FontWeight.w400, color: color)))
      ]);
}
