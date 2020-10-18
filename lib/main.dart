import 'package:flutter/material.dart';
import 'texttospeech.dart';



void main() { 
  runApp(MaterialApp( 
    initialRoute: '/', 
    routes: { 
      '/': (context) => HomeRoute(), 
      '/second': (context) => TexttoSpeech(),  
    }, 
  )); 
} 

class HomeRoute extends StatelessWidget { 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('YOLO'), 
        backgroundColor: Colors.grey[300], 
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
        ], 
      )), 
    ); 
  } 
}



