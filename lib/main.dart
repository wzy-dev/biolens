import 'package:biolens/shelf.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  //For Firebase
  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));

  //For Navigation bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    // statusBarIconBrightness: Brightness.dark,
    // statusBarColor: Color.fromARGB(0, 0, 0, 0),
    systemNavigationBarColor: Color.fromRGBO(241, 246, 249, 1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
}

class MyApp extends StatefulWidget {
  MyApp({this.camera});

  final camera;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Homepage? _home;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    _initialization.then((value) {
      print('init');

      FirebaseAuth.instance.signInAnonymously().then((value) {
        print('log');
        FirebaseFirestore.instance.settings = Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        FirebaseFirestore.instance.enableNetwork().then((value) {
          print('enabled');
          List<Future> query = [
            FirebaseFirestore.instance.collection('products').get(),
            FirebaseFirestore.instance.collection('indications').get(),
            FirebaseFirestore.instance.collection('categories').get(),
          ];

          Future.wait(query).then((value) {
            print('sync');
            FirebaseFirestore.instance.disableNetwork().then((value) {
              print('disable');
              setState(() {
                _home = Homepage(camera: widget.camera);
              });
            });
          });
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('fr', 'FR')],
      title: 'biolens',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(55, 104, 180, 1),
      ),
      home: _home ??
          CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
    );
  }
}
