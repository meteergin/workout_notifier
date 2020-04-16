import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

Soundpool _soundpool;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _soundpool = Soundpool();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Workout Time Interval Notifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final workoutTimeIntervalController = TextEditingController();
  final restingTimeIntervalController = TextEditingController();

  Timer _timer;
  int _counter;
  int _totalSets;
  Future<int> _startSound;
  Future<int> _stopSound;
  int _alarmSoundStreamId;
  Color textColor;

  @override
  void initState() {
    _counter = 0;
    _totalSets = 0;
    super.initState();
    _startSound = _loadStartSound();
    _stopSound = _loadStopSound();
  }

  Future<void> _playStartSound() async {
    var _alarmSound = await _startSound;
    _alarmSoundStreamId = await _soundpool.play(_alarmSound);
  }

  Future<void> _playStopSound() async {
    var _alarmSound = await _stopSound;
    _alarmSoundStreamId = await _soundpool.play(_alarmSound);
  }

  void _start() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    if (workoutTimeIntervalController.text == "") {
      workoutTimeIntervalController.text = "20";
    }

    if (restingTimeIntervalController.text == "") {
      restingTimeIntervalController.text = "10";
    }

    FocusScope.of(context).requestFocus(FocusNode());
    const oneSec = const Duration(seconds: 1);
    _counter = int.parse(workoutTimeIntervalController.text);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          textColor = Colors.green;
          if (_counter < 1) {
            textColor = Colors.red;
            _playStopSound();
            timer.cancel();
            _totalSets++;
            _break();
          } else {
            _counter = _counter - 1;
            textColor = Colors.green;
          }
        },
      ),
    );
  }

  void _break() {
    FocusScope.of(context).requestFocus(FocusNode());
    const oneSec = const Duration(seconds: 1);
    _counter = int.parse(restingTimeIntervalController.text);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_counter < 1) {
            _playStartSound();
            timer.cancel();
            _start();
          } else {
            _counter = _counter - 1;
          }
        },
      ),
    );
  }

  void _stop() {
    setState(() {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
    });
  }

  void _reset() {
    setState(() {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      workoutTimeIntervalController.text = "20";
      restingTimeIntervalController.text = "10";
      _totalSets = 0;
      _counter = 0;
    });
  }

  Future<int> _loadStartSound() async {
    var asset = await rootBundle.load("sounds/start.wav");
    return await _soundpool.load(asset);
  }

  Future<int> _loadStopSound() async {
    var asset = await rootBundle.load("sounds/stop.wav");
    return await _soundpool.load(asset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
                decoration: InputDecoration(
                    labelText: 'Workout time interval in seconds'),
                controller: workoutTimeIntervalController,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly]),
            TextFormField(
                decoration: InputDecoration(
                    labelText: 'Resting time interval in seconds'),
                controller: restingTimeIntervalController,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly]),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: MaterialButton(
                child: Text(
                  'Start',
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                ),
                color: Colors.green,
                onPressed: _start,
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: MaterialButton(
                child: Text(
                  'Stop',
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                ),
                color: Colors.red,
                onPressed: _stop,
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: MaterialButton(
                child: Text(
                  'Reset',
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                ),
                color: Colors.blue,
                onPressed: _reset,
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    '$_counter',
                    style: TextStyle(color: textColor, fontSize: 100.0),
                  ),
                  Divider(),
                  Text(
                    'Total sets: $_totalSets',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
