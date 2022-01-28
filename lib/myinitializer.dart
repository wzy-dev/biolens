import 'package:biolens/models/mydatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sqlbrite/sqlbrite.dart';

class MyInitializer extends StatefulWidget {
  final Widget Function(
          BuildContext context, AsyncSnapshot snapshots, BriteDatabase briteDb)
      onDidInitilize;
  final Widget Function(BuildContext) onLoading;

  const MyInitializer({
    Key? key,
    required this.onDidInitilize,
    required this.onLoading,
  }) : super(key: key);

  @override
  _MyInitializerState createState() => _MyInitializerState();
}

class _MyInitializerState extends State<MyInitializer> {
  late Future<FirebaseApp> _firebaseInitialization;
  late Future<Database> _databaseInitialization;
  late Future<User> _firebaseAuth;

  @override
  void initState() {
    _firebaseInitialization = Firebase.initializeApp();
    // drop : true pour le debuggage (réinitialisation de la base de donnée à chaque rechargement)
    _databaseInitialization = ModelMethods.initDb(drop: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Database>(
        future: _databaseInitialization,
        builder: (context, snapshotDatabase) {
          // Once complete, show your application
          if (snapshotDatabase.connectionState == ConnectionState.done &&
              snapshotDatabase.data != null) {
            return FutureBuilder<FirebaseApp>(
              future: _firebaseInitialization,
              builder: (context, snapshotFirebaseApp) {
                // Once complete, show your application
                if (snapshotFirebaseApp.connectionState ==
                    ConnectionState.done) {
                  return FutureBuilder<User>(
                    future: _firebaseAuth,
                    builder: (context, snapshotFirebaseAuth) {
                      // Once complete, show your application
                      if (snapshotFirebaseAuth.connectionState ==
                          ConnectionState.done) {
                        return widget.onDidInitilize(
                          context,
                          snapshotFirebaseAuth,
                          BriteDatabase(snapshotDatabase.data!, logger: null),
                        );
                      }
                      // Otherwise, show something whilst waiting for initialization to complete
                      return widget.onLoading(context);
                    },
                  );
                }
                // Otherwise, show something whilst waiting for initialization to complete
                return widget.onLoading(context);
              },
            );
          }
          // Otherwise, show something whilst waiting for initialization to complete
          return widget.onLoading(context);
        });
  }
}
