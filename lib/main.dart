// ignore_for_file: cancel_subscriptions
import 'dart:async';

import 'package:biolens/first_open.dart';
import 'package:biolens/models/mydatabase.dart';
import 'package:biolens/myinitializer.dart';
import 'package:biolens/models/myprovider.dart';
import 'package:biolens/shelf.dart';
import 'package:biolens/src/home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlbrite/sqlbrite.dart';

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
  // late Future<FirebaseApp> _firebaseInitialization;
  // late Future<Database> _databaseInitialization;
  bool fullyInitialized = false;
  bool? tutorialReaded;
  late Database briteDb;
  late Future<FirebaseApp> _firebaseInitialization;
  late Future<Database> _databaseInitialization;

  @override
  void initState() {
    SharedPreferences.getInstance().then(
        (prefs) => tutorialReaded = prefs.getBool("tutorialReaded") ?? false);
    _firebaseInitialization = Firebase.initializeApp();
    // drop : true pour le debuggage (réinitialisation de la base de donnée à chaque rechargement)
    _databaseInitialization = ModelMethods.initDb(drop: true);

    Future.wait([
      _databaseInitialization,
      _firebaseInitialization,
    ]).then((value) {
      List list = value;
      briteDb = list[0];
      return FirebaseAuth.instance.signInAnonymously().then((value) {
        if (fullyInitialized) return;
        setState(() => fullyInitialized = true);
      });
    });

    super.initState();
  }

  Future<void> _drawLanding() async {
    // return Homepage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("tutorialReaded", false);
  }

  void _finishTutorial() {
    setState(() {
      tutorialReaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (fullyInitialized == true && tutorialReaded == true) {
      return MultiProvider(
        key: Key(FirebaseAuth.instance.currentUser!.uid),
        providers: MyProvider.generateProvidersList(
            briteDb: BriteDatabase(briteDb, logger: null),
            user: FirebaseAuth.instance.currentUser!),
        child: CustomCupertinoApp(
          home: Homepage(),
        ),
      );
    }

    if (tutorialReaded != false) return FullScreenLoader();

    return CustomCupertinoApp(
      home: FirstOpen(
        tutorialReaded: _finishTutorial,
        loadingFinish: fullyInitialized,
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CupertinoColors.white,
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}

class CustomCupertinoApp extends StatelessWidget {
  const CustomCupertinoApp({Key? key, required this.home}) : super(key: key);

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('fr', 'FR')],
      initialRoute: '/',
      title: 'biolens',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 55, 104, 180),
      ),
      home: home,
    );
  }
}
