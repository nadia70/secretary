import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";
  Map<PermissionGroup, PermissionStatus> permissions;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    initSpeechRecognizer();
  }

  void getPermission() async {
    permissions = await PermissionHandler().requestPermissions([
      PermissionGroup.location,
      PermissionGroup.camera,
      PermissionGroup.locationAlways,
      PermissionGroup.phone,
      PermissionGroup.sensors,
      PermissionGroup.storage,
      PermissionGroup.microphone,
    ]);


  }

  void initSpeechRecognizer(){
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState (()=> _isAvailable = result)
    );

    _speechRecognition.setRecognitionStartedHandler(
        ()=> setState (()=> _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
        (String speech)=> setState (()=> resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
          ()=> setState (()=> _isListening = false),
    );

    _speechRecognition.activate().then(
        (result)=> setState (()=> _isAvailable = result),
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                child: Icon(Icons.refresh),
                mini: true,
                backgroundColor: Colors.red[900],
                onPressed: (){
                  if (_isListening)
                    _speechRecognition.cancel().then(
                        (result) => setState ((){
                          _isListening = result;
                          resultText ="";
                        })
                    );
                },
                  ),
              FloatingActionButton(
                child: Icon(Icons.mic),
                backgroundColor: Colors.pink[600],
                onPressed: (){
                  if(_isAvailable && !_isListening)
                    _speechRecognition
                      .listen(locale: "en_US")
                      .then((result)=> print ('$result'));
                },),
              FloatingActionButton(
                child: Icon(Icons.stop),
                mini: true,
                backgroundColor: Colors.orange[900],
                onPressed: (){
                  if (_isListening)
                    _speechRecognition.stop().then(
                        (result)=> setState (() => _isListening = result),
                    );
                },
                  ),
            ],
          ),
            Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(6.0)
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Text(resultText,
              style: TextStyle(fontSize: 18),),
            )
          ],
        ),
      ),
    );
  }
}
