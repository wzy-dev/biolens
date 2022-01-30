// ignore_for_file: cancel_subscriptions
import 'dart:async';

import 'package:biolens/models/shelf_models.dart';
import 'package:biolens/shelf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlbrite/sqlbrite.dart';

Future<void> main() async {
  //For Firebase
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

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
  InitializationStep _initializationStep = InitializationStep.loading;
  bool? tutorialIsReaded;
  late BriteDatabase _briteDb;

  @override
  void initState() {
    // On cherche si le tutoriel a déjà été lu
    SharedPreferences.getInstance().then((prefs) => setState(
        () => tutorialIsReaded = prefs.getBool("tutorialReaded") ?? false));

    // On lance l'initialialisation de la base de données et de Firebase / FirebaseAuth
    _initializer();

    super.initState();
  }

  void _initializer() {
    // On informe que l'initialisation est en cours
    if (_initializationStep != InitializationStep.loading) {
      setState(() => _initializationStep = InitializationStep.loading);
    }

    // drop : true pour le debuggage (réinitialisation de la base de donnée à chaque rechargement)
    Future.wait([
      ModelMethods.initDb(drop: false),
      Firebase.initializeApp(),
    ]).then(
      (value) {
        // On utilise la database qui a été retournée pour créer la briteDb
        List list = value;
        Database database = list[0];
        _briteDb = BriteDatabase(database, logger: null);

        // Maintenant que Firebase est initialisé on peut connecter l'utilisateur de façon anonyme
        _logger();
      },
    ).onError((error, stackTrace) async {
      // Si l'initialisation échoue on informe pour pouvoir la retenter
      setState(() {
        _initializationStep = InitializationStep.initializationError;
      });
    });
  }

  void _logger() {
    // On log ici l'utilisateur de manière anonyme

    // On informe que l'initialisation est en cours
    if (_initializationStep != InitializationStep.loading) {
      setState(() => _initializationStep = InitializationStep.loading);
    }

    // Maintenant que Firebase est initialisé on peut connecter l'utilisateur de façon anonyme
    FirebaseAuth.instance.signInAnonymously().then(
      (value) {
        // Si la connexion est un succès on informe via le state une fois pour éviter les boucles
        if (_initializationStep == InitializationStep.success) return;
        setState(() => _initializationStep = InitializationStep.success);
      },
    ).onError((error, stackTrace) async {
      // Si la connexion échoue on informe pour pouvoir la retenter
      setState(() {
        _initializationStep = InitializationStep.loginError;
      });
    });
  }

  void _finishTutorial() {
    // Qunad on a fini le tutoriel on change le state de manière à changer de CupertinoApp
    setState(() {
      tutorialIsReaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si l'initialisation est un succès et qu'on a déjà vu le tutoriel, on affiche le contenu
    if (_initializationStep == InitializationStep.success &&
        tutorialIsReaded == true) {
      return MultiProvider(
        key: Key(FirebaseAuth.instance.currentUser!.uid),
        providers: MyProvider.generateProvidersList(
            briteDb: _briteDb, user: FirebaseAuth.instance.currentUser!),
        child: CustomCupertinoApp(
          home: Homepage(),
        ),
      );
    }

    // Ecran de chargement avant le contenu pour ceux qui ont déjà vu le tutoriel
    if (tutorialIsReaded != false) return FullScreenLoader();

    // Tutoriel pour la première connexion
    return CustomCupertinoApp(
      home: FirstOpen(
        finishTutorial: _finishTutorial,
        initializationStep: _initializationStep,
        initializer: _initializer,
        logger: _logger,
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
