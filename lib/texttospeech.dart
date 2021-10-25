import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'utils/elevatedButton.dart';

enum TtsState { playing, stopped, paused, continued }

class TextToSpeech extends StatefulWidget {
  const TextToSpeech({Key key}) : super(key: key);

  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  FlutterTts flutterTts;
  String language;
  String engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String _newVoiceText;
  String _fileNameText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String selectedEngine) {
    flutterTts.setEngine(selectedEngine);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  void _fileName(String text) {
    setState(() {
      _fileNameText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // this is all you need
        title: Text("Text to Speech"),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _inputSection(),
            _btnSection(),
            _futureBuilder(),
            _buildSliders(),
            _save(),
            // if (isAndroid) _getMaxSpeechInputLengthSection(),
          ],
        ),
      ),
    );
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(32),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 5,
        maxLength: 4000,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), labelText: 'Enter Text'),
        onChanged: (String value) {
          _onChange(value);
        },
      ));

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
      ]));
    } else {
      return Container(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
        _buildButtonColumn(
            Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
      ]));
    }
  }

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.all(24),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "Language",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
          hint: Text("Language"),
        ),
        Visibility(
          visible: isAndroid,
          child:
              Text(isCurrentLanguageInstalled ? "Installed" : "Not Installed"),
        ),
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
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
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Volume",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Slider(
            value: volume,
            onChanged: (newVolume) {
              setState(() => volume = newVolume);
            },
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: "Volume: $volume",
            activeColor: Color(0xFF1BA9CC))
      ],
    );
  }

  Widget _pitch() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "Pitch",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      Slider(
        value: pitch,
        onChanged: (newPitch) {
          setState(() => pitch = newPitch);
        },
        min: 0.5,
        max: 2.0,
        divisions: 15,
        label: "Pitch: $pitch",
        activeColor: Color(0xFF21B8E0),
      )
    ]);
  }

  Widget _rate() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "Rate",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      Slider(
        value: rate,
        onChanged: (newRate) {
          setState(() => rate = newRate);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Rate: $rate",
        activeColor: Color(0xFF31C3E7),
      )
    ]);
  }

  Widget _save() {
    return Padding(
        padding: EdgeInsets.all(24),
        child: CustomElevatedButton(
            onPressed: () {
              _newVoiceText != null
                  ? showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Save Text Audio'),
                          content: TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Name of File'),
                              onChanged: (String value) {
                                _fileName(value);
                              }),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  await flutterTts.awaitSynthCompletion(true);
                                  await flutterTts.synthesizeToFile(
                                      _newVoiceText,
                                      Platform.isAndroid
                                          ? _fileNameText + ".wav"
                                          : _fileNameText + ".caf");
                                  Navigator.of(context).pop();
                                },
                                child: Text("Save")),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ))),
                            const SizedBox(
                              width: 8,
                            )
                          ],
                        );
                      })
                  : null;
            },
            text: 'Save Speech'));
  }
}
