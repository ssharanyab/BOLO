import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/services.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key key}) : super(key: key);

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  bool _hasSpeech = false;
  bool _logEvents = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        finalTimeout: Duration(milliseconds: 0));
    if (hasSpeech) {
      // Get the list of languages installed on the supporting platform so they
      // can be displayed in the UI for selection by the user.
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Speech to Text"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Color(0xFF1BA9CC), Color(0xFF2BCECA)],
            ),
          ),
        ), //     LinearGradient(begin: Color(0xFF1BA9CC), end: Color(0xFF1BA9CC)),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: 32,
        ),
        Text(
          'Speech Recognition Available',
          style: TextStyle(fontSize: 22.0),
        ),
        Column(
          children: <Widget>[
            SpeechControlWidget(_hasSpeech, speech.isListening, startListening,
                stopListening, cancelListening),
            SessionOptionsWidget(_currentLocaleId, _switchLang, _localeNames,
                _logEvents, _switchLogging),
          ],
        ),
        Expanded(
          flex: 4,
          child: RecognitionResultsWidget(lastWords: lastWords, level: level),
        ),
        lastError == ""
            ? const SizedBox()
            : Expanded(
                flex: 1,
                child: ErrorWidget(lastError: lastError),
              ),
        SpeechStatusWidget(speech: speech),
      ]),
    );
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('Start Listening');
    lastWords = '';
    lastError = '';
    // Note that `listenFor` is the maximum, not the minimun, on some
    // recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords}';
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  void _switchLogging(bool val) {
    setState(() {
      _logEvents = val ?? false;
    });
  }
}

/// Displays the most recently recognized words and the sound level.
class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    Key key,
    this.lastWords,
    this.level,
  }) : super(key: key);

  final String lastWords;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        Center(
          child: Text(
            'Recognized Words',
            style: TextStyle(fontSize: 22.0),
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).selectedRowColor,
                child: Center(
                  child: Text(
                    lastWords,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                  bottom: 10,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: .26,
                                    spreadRadius: level * 1.5,
                                    color: Colors.black.withOpacity(.05))
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: () => null,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        lastWords == ""
                            ? const SizedBox()
                            : Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.file_copy_rounded),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                              ClipboardData(text: lastWords))
                                          .then((result) {
                                        final snackBar = SnackBar(
                                          content: Text('Copied to Clipboard'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      });
                                    },
                                  ),
                                ),
                              ),
                      ])),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Speech Recognition Available',
        style: TextStyle(fontSize: 22.0),
      ),
    );
  }
}

/// Display the current error status from the speech
/// recognizer
class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    Key key,
    this.lastError,
  }) : super(key: key);

  final String lastError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        Center(
          child: Text(
            'Error Status',
            style: TextStyle(fontSize: 18.0, color: Colors.red),
          ),
        ),
        Center(
          child: Text(lastError),
        ),
      ],
    );
  }
}

/// Controls to start and stop speech recognition
class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(this.hasSpeech, this.isListening,
      this.startListening, this.stopListening, this.cancelListening,
      {Key key})
      : super(key: key);

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  final void Function() cancelListening;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: !hasSpeech || isListening ? null : startListening,
          child: Text('Start'),
        ),
        TextButton(
          onPressed: isListening ? stopListening : null,
          child: Text('Stop'),
        ),
        TextButton(
          onPressed: isListening ? cancelListening : null,
          child: Text('Cancel'),
        )
      ],
    );
  }
}

class SessionOptionsWidget extends StatelessWidget {
  const SessionOptionsWidget(this.currentLocaleId, this.switchLang,
      this.localeNames, this.logEvents, this.switchLogging,
      {Key key})
      : super(key: key);

  final String currentLocaleId;
  final void Function(String) switchLang;
  final void Function(bool) switchLogging;
  final List<LocaleName> localeNames;
  final bool logEvents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Language: '),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            alignment: Alignment.center,
            onChanged: (selectedVal) => switchLang(selectedVal),
            value: currentLocaleId,
            items: localeNames
                .map(
                  (localeName) => DropdownMenuItem(
                    value: localeName.localeId,
                    child: Text(localeName.name),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Display the current status of the listener
class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    Key key,
    this.speech,
  }) : super(key: key);

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFF1BA9CC), Color(0xFF2BCECA)],
        ),
      ),
      child: Center(
        child: speech.isListening
            ? Text(
                "I'm listening...",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              )
            : Text(
                'Not listening',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
