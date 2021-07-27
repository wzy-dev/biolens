import 'package:biolens/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

void main() {
  //For Firebase
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  //For Navigation bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color.fromRGBO(241, 246, 249, 1),
    statusBarColor: Color.fromARGB(0, 0, 0, 0),
  ));
}

class MyApp extends StatefulWidget {
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
                _home = Homepage();
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
