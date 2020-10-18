import 'package:flutter/material.dart';
import 'texttospeech.dart';
import 'speechtotext.dart';


void main() { 
  runApp(MaterialApp( 
    initialRoute: '/', 
    routes: { 
      '/': (context) => HomeRoute(), 
      '/second': (context) => TexttoSpeech(), 
      '/third': (context) => SpeechtoText(), 
    }, 
  )); 
} 


class HomeRoute extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('YOLO'), 
        backgroundColor: Colors.green, 
      ), 
      body: Center( 
          child: Column( 
          children: <Widget>[ 
          RaisedButton( 
            child: Text('Text to Speech!'), 
            onPressed: () { 
              Navigator.pushNamed(context, '/second'); 
            }, 
          ), 
          RaisedButton( 
            child: Text('Speech to text!'), 
            onPressed: () { 
              Navigator.pushNamed(context, '/third'); 
            }, 
          ), 
        ], 
      )), 
    ); 
  } 
}



