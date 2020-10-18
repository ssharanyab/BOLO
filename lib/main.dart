import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Yolo());
  
  }
}
class Yolo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return new Scaffold(
        body: Center(
            child: RaisedButton(
                child: Text('Text to speech'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TexttoSpeech()),
                  );
                }),),
      );
  }
}

class TexttoSpeech extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    Future speak(String text) async {
      await flutterTts.speak(text);
    }

    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: textEditingController,
            ),
            RaisedButton(
                child: Text('Press this to say'),
                onPressed: () => speak(textEditingController.text)),
          ],
        ));
  }
}
