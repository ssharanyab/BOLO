import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TexttoSpeech extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    Future speak(String text) async {
      await flutterTts.speak(text);
    }
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: textEditingController,
          ),
          RaisedButton(
        child: Text('Press this to say'),
        onPressed: ()=> speak(textEditingController.text)),
        ],)
      
    );
  }
}