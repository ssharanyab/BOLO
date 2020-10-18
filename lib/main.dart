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
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('YOLO'),
          backgroundColor: Colors.grey[900],
        ),
        body: Center(
          child: 
              Column(
                children: <Widget>[
                  Container(
                    height: 550,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [Colors.grey[500], Colors.grey[900]],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text('This app is mainly intended for people differently abled people who cannot speak but can hear. It is quiet challenging for these people to face real world. Our app just makes a small attempt to help these people by providing a way to communicate with the world. Our app speaks the texts that the user writes!',
                    textAlign: TextAlign.justify ,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,               
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Text to Speech!'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/second');
                    },
                  ),
                ],
              ),
        ));
  }
}
