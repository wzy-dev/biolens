import 'package:biolens/shelf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
              FirebaseFirestore.instance
                  .collection('tags')
                  .where("editedAt", isGreaterThan: editedAt)
                  .get()
            ];

            Future.wait(query).then((value) {
              print('sync');

              sharedPreferences.setInt('updatedAt', startTimestamp);

              FirebaseFirestore.instance.disableNetwork().then((value) {
                print('disable');

                FirebaseAnalytics.instance.logAppOpen();

                setState(() {
                  _home = Homepage();
                });
              }).onError((error, stackTrace) async {
                _drawError(
                    "Impossible de se déconnecter du réseau (code 4000)");
              });
            }).onError((error, stackTrace) async {
              _drawError("Synchronisation impossible (code 3000)");
            });
          }).onError((error, stackTrace) async {
            _drawError("Impossible de se connecter au réseau (code 2000)");
          });
        }).onError((error, stackTrace) async {
          _drawError(
              "Vous devez être connecté à Internet pour accéder la première fois à biolens");
        }).timeout(Duration(seconds: 5), onTimeout: () async {
          _drawError(
              "Votre connexion Internet semble insuffisante, veuillez vérifier vos paramètres réseaux");
        });
      }).onError((error, stackTrace) async {
        _drawError("Accès impossible au préférences partagées (code 1000)");
      });
    });
  }

  void _drawError(String error) {
    return setState(() {
      _home = CupertinoPageScaffold(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Color.fromRGBO(105, 20, 28, 1),
                    border: Border.all(
                      color: Color.fromRGBO(137, 24, 36, 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _home = null;
                    });
                    _initializeAction();
                  },
                  child: Text("Rafraîchir"),
                ),
              ],
            ),
          ),
        ),
      );
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
      // debugShowCheckedModeBanner: false,
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
      home: _home ??
          CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
    );
  }
}
