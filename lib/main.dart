// ignore_for_file: cancel_subscriptions
import 'dart:async';

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
  @override
  void initState() {
    Firebase.initializeApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyInitializer(
      onDidInitilize: (initContext, snapshot, briteDb) {
        FirebaseAnalytics.instance.logAppOpen();

        // On crée un stream d'user et on le reconnecte
        Stream<User?> _streamUser = FirebaseAuth.instance.authStateChanges();
        FirebaseAuth.instance.signInAnonymously();

        return StreamBuilder<User?>(
            stream: _streamUser,
            builder: (context, snapshotUser) {
              if (snapshotUser.connectionState != ConnectionState.active ||
                  snapshotUser.data == null) return FullScreenLoader();

              return MultiProvider(
                key: Key(snapshotUser.data!.uid),
                providers: MyProvider.generateProvidersList(
                    briteDb: briteDb, user: snapshotUser.data!),
                child: CupertinoApp(
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
                  home: Homepage(),
                ),
              );
            });
      },
      onLoading: (loadingContext) => Center(
        child: FullScreenLoader(),
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
