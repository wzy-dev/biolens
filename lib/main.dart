import 'package:biolens/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  //For Firebase
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  //For Navigation bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Color.fromARGB(0, 0, 0, 0),
    systemNavigationBarColor: Color.fromRGBO(241, 246, 249, 1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _home;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<SharedPreferences> _getLastEditTimestap() async {
    return await SharedPreferences.getInstance();
    // return prefs.getInt('updatedAt') ?? DateTime.now().millisecondsSinceEpoch;
  }

  void _initializeAction() {
    _initialization.then((value) {
      print('init');

      _getLastEditTimestap().then((sharedPreferences) {
        print(FirebaseAuth.instance.currentUser);
        int editedAt = FirebaseAuth.instance.currentUser == null
            ? 0
            : sharedPreferences.getInt('updatedAt') ?? 0;
        int startTimestamp = DateTime.now().millisecondsSinceEpoch;

        FirebaseAuth.instance.signInAnonymously().then((value) {
          print('log');
          FirebaseFirestore.instance.settings = Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
          FirebaseFirestore.instance.enableNetwork().then((value) {
            print('enabled');

            print(editedAt);
            List<Future> query = [
              FirebaseFirestore.instance
                  .collection('products')
                  .where("editedAt", isGreaterThan: editedAt)
                  .get(),
              FirebaseFirestore.instance
                  .collection('indications')
                  .where("editedAt", isGreaterThan: editedAt)
                  .get(),
              FirebaseFirestore.instance
                  .collection('categories')
                  .where("editedAt", isGreaterThan: editedAt)
                  .get(),
            ];

            Future.wait(query).then((value) {
              print('sync');

              sharedPreferences.setInt('updatedAt', startTimestamp);

              FirebaseFirestore.instance.disableNetwork().then((value) {
                print('disable');
                setState(() {
                  _home = Homepage();
                });
              });
            });
          });
        });
      }).onError((error, stackTrace) async {
        setState(() {
          _home = CupertinoPageScaffold(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _home = null;
                    });
                    _initializeAction();
                  },
                  child: Text(
                      "Vous devez être connecté à Internet pour votre premier accès à biolens"),
                ),
              ),
            ),
          );
        });
      });
    });
  }

  @override
  void initState() {
    _initializeAction();

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
