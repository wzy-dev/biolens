import 'package:biolens/models/products/products.dart';
import 'package:biolens/models/tags/tags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sqlbrite/sqlbrite.dart';

class MyProvider {
  static Map<String, dynamic> _mapFromFirestore(
      {required String name, required item}) {
    switch (name) {
      case "products":
        return Product.fromFirestore(item).toJson();
      case "tags":
        return Tag.fromFirestore(item).toJson();
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
      Provider<BriteDatabase>(
        create: (_) => briteDb,
      ),
    ];
  }
}
