import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'constants.dart' show defaultAlarmAudioPath;
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final audioCache = AudioCache();
  final AudioPlayer audioPlayer = AudioPlayer();
  final double maxCowSize = 560;
  final String? title;
  late final Future<Uri> futureUri = audioCache.load(defaultAlarmAudioPath);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  bool _isCowUp = true;
  Uri? _uri;
  late AnimationController _currentController;
  late AnimationController _controllerUp;
  late AnimationController _controllerDown;
  double? _accelerometerY;
  List<double>? _accelerometerValues;
  late StreamSubscription<dynamic> _streamSubscription;
  bool _isPositiveY = true;
  //final _streamSubscription = StreamSubscription;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _boxClick() async {
    if (_uri == null) {
      _uri = await widget.futureUri;
      widget.audioPlayer.setUrl(_uri.toString());
    }

    _incrementCounter();
    if (_currentController.isAnimating) {
      _currentController.stop();
      widget.audioPlayer.pause();
    } else {
      if (_currentController.isCompleted) {
        AnimationController previousController = _currentController;

        setState(() {
          _isCowUp = !_isCowUp;
          _currentController = _isCowUp ? _controllerUp : _controllerDown;
        });
        previousController.reset();
      }
      _currentController.forward();
      widget.audioPlayer.play(_uri.toString(), isLocal: true);
    }
  }

  void handleAccelerometerStreamEvent(AccelerometerEvent event) {
    setState(() {
      _accelerometerValues = <double>[event.x, event.y, event.z];
    });
  }

  @override
  void initState() {
    _controllerUp = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
        lowerBound: 0.0,
        upperBound: 0.5);
    _controllerDown = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0);
    _currentController = _controllerUp;
    _streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        handleAccelerometerStreamEvent(event);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _controllerUp.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final accelerometerY = accelerometer![1];
    //final accelerometerY = _accelerometerY.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have clicked the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometerY'),
                Text('isPosY: $_isPositiveY')
              ],
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                  maxWidth: widget.maxCowSize,
                  maxHeight: widget.maxCowSize,
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RotationTransition(
                    turns:
                        Tween(begin: 0.0, end: 1.0).animate(_currentController),
                    child: TextButton(
                      child: Text("🐮"),
                      onPressed: _boxClick,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _boxClick,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
