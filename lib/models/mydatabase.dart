import 'dart:convert';

import 'package:biolens/models/shelf_models.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:sqlbrite/sqlbrite.dart';

class ModelMethods {
  static Map<String, dynamic> listToJson(
      {required Map<String, dynamic> json, required String property}) {
    Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    jsonCopy[property] = jsonEncode(jsonCopy[property]);
    return jsonCopy;
  }

  static Map<String, dynamic> jsonToList(
      {required Map<String, dynamic> json, required String property}) {
    Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    jsonCopy[property] = jsonDecode(jsonCopy[property]);
    return jsonCopy;
  }

  static Map<String, dynamic> jsonToNames(
      {required Map<String, dynamic> json, required String property}) {
    Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    jsonCopy[property] = Names.fromJson(jsonDecode(jsonCopy[property]));
    return jsonCopy;
  }

  static Map<String, dynamic> namesToJson(
      {required Map<String, dynamic> json, required String property}) {
    Map<String, dynamic> jsonCopy = Map<String, dynamic>.from(json);
    Names names = jsonCopy[property] as Names;
    jsonCopy[property] = jsonEncode(names.toJson());
    return jsonCopy;
  }

  static Map<String, dynamic> boolToInt(
      {required Map<String, dynamic> json, required String property}) {
    json[property] == true || json[property] == 1
        ? json[property] = 1
        : json[property] = 0;
    return json;
  }

  static Map<String, dynamic> intToBool(
      {required Map<String, dynamic> json, required String property}) {
    json[property] == true || json[property] == 1
        ? json[property] = true
        : json[property] = false;
    return json;
  }

  static Future<bool> tableExists(DatabaseExecutor db, String table) async {
    int count = firstIntValue(await db.query('sqlite_master',
            columns: ['COUNT(*)'],
            where: 'type = ? AND name = ?',
            whereArgs: ['table', table])) ??
        0;
    return count > 0;
  }

  static Future<bool> lastUpdateRowExist(
      DatabaseExecutor db, String table) async {
    int count = firstIntValue(await db.query("last_update",
            where: "tableName = ?", whereArgs: [table], limit: 1)) ??
        0;
    return count > 0;
  }

  static Future<Database> initDb({bool drop = false}) async {
    final db = await openDatabase('mywine_db.db');

    if (drop) {
      await db.execute("DROP TABLE IF EXISTS last_update");
      await db.execute("DROP TABLE IF EXISTS products");
      await db.execute("DROP TABLE IF EXISTS tags");
      await db.execute("DROP TABLE IF EXISTS universities");
      await db.execute("DROP TABLE IF EXISTS annotations");
      await db.execute("DROP TABLE IF EXISTS mode");
    }

    if (!await ModelMethods.tableExists(db, "products")) {
      // Create a table
      await db.execute('''CREATE TABLE products (
            id STRING PRIMARY KEY,
            editedAt INTEGER,
            enabled INTEGER,
            name STRING,
            brand STRING,
            source STRING,
            picture STRING,
            tagPicture STRING,
            cookbook STRING,
            ids STRING,
            ingredients STRING,
            names STRING,
            precautions STRING
          )''');
    }

    if (!await ModelMethods.tableExists(db, "tags")) {
      // Create a table
      await db.execute('''CREATE TABLE tags (
            id STRING PRIMARY KEY,
            editedAt INTEGER,
            enabled INTEGER,
            name STRING
          )''');
    }

    if (!await ModelMethods.tableExists(db, "universities")) {
      // Create a table
      await db.execute('''CREATE TABLE universities (
            id STRING PRIMARY KEY,
            editedAt INTEGER,
            enabled INTEGER,
            name STRING,
            products STRING,
            annotations STRING
          )''');
    }

    if (!await ModelMethods.tableExists(db, "annotations")) {
      // Create a table
      await db.execute('''CREATE TABLE annotations (
            id STRING PRIMARY KEY,
            editedAt INTEGER,
            enabled INTEGER,
            university STRING,
            note STRING,
            product STRING
          )''');
    }

    if (!await ModelMethods.tableExists(db, "mode")) {
      // Create a table
      await db.execute(
          'CREATE TABLE mode (id INTEGER PRIMARY KEY AUTOINCREMENT, mode STRING, university STRING)');
    }

    if (!await ModelMethods.tableExists(db, "last_update")) {
      // Create a table
      await db.execute(
          'CREATE TABLE last_update (id INTEGER PRIMARY KEY AUTOINCREMENT, tableName STRING, datetime INTEGER)');
    }

    if (!await lastUpdateRowExist(db, "products"))
      db.insert("last_update", {"tableName": "products", "datetime": 0});
    if (!await lastUpdateRowExist(db, "tags"))
      db.insert("last_update", {"tableName": "tags", "datetime": 0});
    if (!await lastUpdateRowExist(db, "universities"))
      db.insert("last_update", {"tableName": "universities", "datetime": 0});
    if (!await lastUpdateRowExist(db, "annotations"))
      db.insert("last_update", {"tableName": "annotations", "datetime": 0});
    if (!await lastUpdateRowExist(db, "mode"))
      db.insert("last_update", {"tableName": "mode", "datetime": 0});

    return db;
  }
}
