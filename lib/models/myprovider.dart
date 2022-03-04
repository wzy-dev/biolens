import 'package:biolens/models/shelf_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sqlbrite/sqlbrite.dart';

class MyProvider {
  static Mode? getCurrentMode(BuildContext context, {bool listen = true}) {
    List<Mode> listMode = Provider.of<List<Mode>>(context, listen: listen);

    Mode? mode;

    if (listMode.length > 0) {
      mode = listMode.first;
    }

    return mode;
  }

  static University? getCurrentUniversity(BuildContext context) {
    Mode? mode = getCurrentMode(context);

    if (mode == null) mode = Mode(mode: Modes.all);

    if (mode.mode == Modes.all) return null;

    return Provider.of<List<University>>(context, listen: true)
        .firstWhere((university) => university.id == mode!.university);
  }

  static Map<String, dynamic> _mapFromFirestore(
      {required String name, required item}) {
    switch (name) {
      case "products":
        return Product.fromFirestore(item).toJson();
      case "tags":
        return Tag.fromFirestore(item).toJson();
      case "universities":
        return University.fromFirestore(item).toJson();
      case "annotations":
        return Annotation.fromFirestore(item).toJson();
      default:
        print("Add an enter in the _mapFromFirstore function");
        return {};
    }
  }

  static void createAListener({
    required String tableName,
    required BriteDatabase briteDb,
    required User? user,
  }) {
    briteDb
        .query(
      "last_update",
      where: "tableName = ?",
      whereArgs: [tableName],
      limit: 1,
    )
        .then((lastUpdateMap) {
      int lastUpdate = int.parse(lastUpdateMap[0]["datetime"].toString());
      int datetime = DateTime.now().toUtc().millisecondsSinceEpoch.toInt();

      FirebaseFirestore.instance
          .collection(tableName)
          .where("editedAt", isGreaterThan: lastUpdate)
          .snapshots()
          .listen((value) {
        for (var item in value.docs) {
          briteDb.insert(
            tableName,
            _mapFromFirestore(item: item, name: tableName),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        briteDb.update(
          "last_update",
          {"datetime": datetime},
          where: "tableName = ?",
          whereArgs: [tableName],
        );
      })
        ..onError((error, stackTrace) {
          print(error);
          print(tableName);
        });
    });
  }

  static void createASubListener({
    required String tableName,
    required BriteDatabase briteDb,
    required User? user,
    List<String>? whereList,
  }) {
    briteDb
        .query(
      "last_update",
      where: "tableName = ?",
      whereArgs: [tableName],
      limit: 1,
    )
        .then((lastUpdateMap) {
      int lastUpdate = int.parse(lastUpdateMap[0]["datetime"].toString());
      int datetime = DateTime.now().toUtc().millisecondsSinceEpoch.toInt();

      FirebaseFirestore.instance
          .collectionGroup(tableName)
          .where("editedAt", isGreaterThan: lastUpdate)
          .snapshots()
          .listen((value) {
        for (var item in value.docs) {
          briteDb.insert(
            tableName,
            _mapFromFirestore(item: item, name: tableName),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        briteDb.update(
          "last_update",
          {"datetime": datetime},
          where: "tableName = ?",
          whereArgs: [tableName],
        );
      })
        ..onError((error, stackTrace) {
          print(error);
          print(tableName);
        });
    });
  }

  static generateProvidersList(
      {required BriteDatabase briteDb, required User user}) {
    return [
      StreamProvider<List<Product>>(
        create: (_) {
          createAListener(briteDb: briteDb, tableName: "products", user: user);

          return briteDb.createQuery(
            "products",
            where: 'enabled = ?',
            whereArgs: ['1'],
          ).mapToList((row) => Product.fromJson(row));
        },
        initialData: [],
      ),
      StreamProvider<List<Tag>>(
        create: (_) {
          createAListener(briteDb: briteDb, tableName: "tags", user: user);

          return briteDb.createQuery(
            "tags",
            where: 'enabled = ?',
            whereArgs: ['1'],
          ).mapToList((row) => Tag.fromJson(row));
        },
        initialData: [],
      ),
      StreamProvider<List<University>>(
        create: (_) {
          createAListener(
              briteDb: briteDb, tableName: "universities", user: user);

          return briteDb.createQuery(
            "universities",
            where: 'enabled = ?',
            whereArgs: ['1'],
          ).mapToList((row) => University.fromJson(row));
        },
        initialData: [],
      ),
      StreamProvider<List<Annotation>>(
        create: (_) {
          createASubListener(
              briteDb: briteDb, tableName: "annotations", user: user);

          return briteDb.createQuery(
            "annotations",
            where: 'enabled = ?',
            whereArgs: ['1'],
          ).mapToList((row) => Annotation.fromJson(row));
        },
        initialData: [],
      ),
      StreamProvider<List<Mode>>(
        create: (_) {
          return briteDb
              .createQuery(
                "mode",
                limit: 1,
              )
              .mapToList((row) => Mode.fromJson(row));
        },
        initialData: [],
      ),
      Provider<BriteDatabase>(
        create: (_) => briteDb,
      ),
    ];
  }
}
