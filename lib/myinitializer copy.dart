// import 'package:biolens/models/mydatabase.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:sqlbrite/sqlbrite.dart';

// class MyInitializer extends StatefulWidget {
//   final Widget Function(
//           BuildContext context, AsyncSnapshot snapshots, BriteDatabase briteDb)
//       onDidInitilize;
//   final Widget Function(BuildContext) onLoading;

//   const MyInitializer({
//     Key? key,
//     required this.onDidInitilize,
//     required this.onLoading,
//   }) : super(key: key);

//   @override
//   _MyInitializerState createState() => _MyInitializerState();
// }

// class _MyInitializerState extends State<MyInitializer> {
//   late Future<FirebaseApp> _firebaseInitialization;
//   late Future<Database> _databaseInitialization;

//   @override
//   void initState() {
//     _firebaseInitialization = Firebase.initializeApp();
//     // drop : true pour le debuggage (réinitialisation de la base de donnée à chaque rechargement)
//     _databaseInitialization = ModelMethods.initDb(drop: true);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: Future.wait([_databaseInitialization, _firebaseInitialization]),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             List data = snapshot.data! as List;
//             Database database = data[0];
//             return widget.onDidInitilize(
//               context,
//               snapshot,
//               BriteDatabase(database, logger: null),
//             );
//           }
//           // Database database = snapshot.data![0] as Database;
//           // // Once complete, show your application
//           // if (snapshot.connectionState == ConnectionState.done) {
//           //   return widget.onDidInitilize(
//           //     context,
//           //     snapshot,
//           //     BriteDatabase(snapshot.data!, logger: null),
//           //   );
//           // }
//           // Otherwise, show something whilst waiting for initialization to complete
//           return widget.onLoading(context);
//         });
//   }
// }
