import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splashscreen.dart';
import 'texttospeech.dart';
import 'utils/elevatedButton.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    theme: ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
      focusColor: Color(0xFF1BA9CC),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: outlineInputBorder(Colors.transparent),
        focusedBorder: outlineInputBorder(Color(0xFF1BA9CC)),
        errorBorder: outlineInputBorder(Colors.red[200]),
        focusedErrorBorder: outlineInputBorder(Colors.red),
        filled: true,
      ),
    ),
    routes: {
      '/': (context) => SplashScreen(),
      '/home': (context) => HomeScreen(),
      '/tts': (context) => TextToSpeech(),
    },
  ));
}

OutlineInputBorder outlineInputBorder(color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color));

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 64),
          Image.asset("assets/images/comhelper_logo.png",
              width: 200, fit: BoxFit.fitWidth),
          Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'This app is mainly intended for people differently abled people who cannot speak but can hear. It is quiet challenging for these people to face real world. Our app just makes a small attempt to help these people by providing a way to communicate with the world. Our app speaks the texts that the user writes!',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: CustomElevatedButton(
              text: "Text to Speech",
              onPressed: () {
                Navigator.pushNamed(context, '/tts');
              },
            ),
          )
          // Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 32),
          //     child: ElevatedButton(
          //         onPressed: () {
          //           Navigator.pushNamed(context, '/tts');
          //         },
          //         child: Text('Text to Speech')))
        ],
      ),
    )));
  }
}
