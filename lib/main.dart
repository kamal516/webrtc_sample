// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:webrtc_tutorial/signaling.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// import 'package:quiver/async.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:open_file/open_file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  bool recording = false;
  int _time = 0;

  // requestPermissions() async {
  //   await PermissionHandler().requestPermissions([
  //     PermissionGroup.storage,
  //     PermissionGroup.photos,
  //     PermissionGroup.microphone,
  //   ]);
  // }

  // void startTimer() {
  //   CountdownTimer countDownTimer = new CountdownTimer(
  //     new Duration(seconds: 1000),
  //     new Duration(seconds: 1),
  //   );

  //   var sub = countDownTimer.listen(null);
  //   sub.onData((duration) {
  //     setState(() => _time++);
  //   });

  //   sub.onDone(() {
  //     print("Done");
  //     sub.cancel();
  //   });
  // }

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    // requestPermissions();
    // startTimer();
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  // startScreenRecord(bool audio) async {
  //   bool start = false;

  //   if (audio) {
  //     start = await FlutterScreenRecording.startRecordScreenAndAudio("Title");
  //   } else {
  //     start = await FlutterScreenRecording.startRecordScreen("Title");
  //   }

  //   if (start) {
  //     setState(() => recording = !recording);
  //   }

  //   return start;
  // }

  // stopScreenRecord() async {
  //   String path = await FlutterScreenRecording.stopRecordScreen;
  //   setState(() {
  //     recording = !recording;
  //   });
  //   print("Opening video");
  //   print(path);
  //   OpenFile.open(path);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video app"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                },
                child: Text("Open camera & microphone"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  roomId = await signaling.createRoom(_remoteRenderer);
                  textEditingController.text = roomId;
                  setState(() {});
                },
                child: Text("Create room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  signaling.joinRoom(
                    textEditingController.text,
                    _remoteRenderer,
                  );
                },
                child: Text("Join room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("Hangup"),
              )
            ],
          ),
          // !recording
          //     ? Center(
          //         child: RaisedButton(
          //           child: Text("Record Screen & audio"),
          //           onPressed: () => startScreenRecord(true),
          //         ),
          //       )
          //     : Center(
          //         child: RaisedButton(
          //           child: Text("Stop Record"),
          //           onPressed: () => stopScreenRecord(),
          //         ),
          //       ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
