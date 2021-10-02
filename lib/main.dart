import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'constants.dart' show defaultAlarmAudioPath;
//import 'package:flutter_emoji/flutter_emoji.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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
  final String? title;
  late final Future<Uri> futureUri = audioCache.load(defaultAlarmAudioPath);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  Uri? uri;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _boxClick() async {
    //_make_noise();
    if (uri == null) {
      uri = await widget.futureUri;
      widget.audioPlayer.setUrl(uri.toString());
    }

    _incrementCounter();
    if (_controller.isAnimating) {
      _controller.stop();
      //widget.audioPlayer.pause();
    } else {
      if (_controller.isCompleted) _controller.reset();
      _controller.forward();
      widget.audioPlayer.play(uri.toString(), isLocal: true);
    }
  }

  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                    //child: Icon(Icons.expand_less),
                    child: Text(
                      "🐮",
                    )),
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
