import 'dart:convert';

import 'package:biolens/models/mydatabase.dart';
import 'package:biolens/models/ids/ids.dart';
import 'package:biolens/models/names/names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'products.g.dart';

@JsonSerializable()
class Product {
  // Main
  String id;
  int editedAt;
  bool? enabled;

  // Custom
  String name;
  String brand;
  String? source;
  String? picture;
  String? tagPicture;
  List<String> cookbook;
  List<String> ingredients;
  List<String> precautions;
  Ids ids;
  Names names;

  Product({
    required this.id,
    required this.editedAt,
    required this.brand,
    this.enabled = false,
    required this.name,
    this.source,
    this.picture,
    this.tagPicture,
    this.cookbook = const [],
    this.ingredients = const [],
    this.precautions = const [],
    required this.ids,
    required this.names,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);
    jsonCopy = ModelMethods.intToBool(json: jsonCopy, property: "enabled");
    jsonCopy = ModelMethods.jsonToList(json: jsonCopy, property: "cookbook");
    jsonCopy = ModelMethods.jsonToList(json: jsonCopy, property: "ingredients");
    jsonCopy = ModelMethods.jsonToList(json: jsonCopy, property: "precautions");

    // From String to Map
    Map<String, dynamic> ids = jsonDecode(jsonCopy["ids"]);
    ids["indications"] = jsonDecode(ids["indications"]);
    ids["tags"] = jsonDecode(ids["tags"]);
    jsonCopy["ids"] = ids;

    // From String to Map
    Map<String, dynamic> names = jsonDecode(jsonCopy["names"]);
    names["indications"] = jsonDecode(names["indications"]);
    names["tags"] = jsonDecode(names["tags"]);
    jsonCopy["names"] = names;

    return _$ProductModelFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$ProductModelToJson(this);
    json = ModelMethods.boolToInt(json: json, property: "enabled");
    json = ModelMethods.listToJson(json: json, property: "cookbook");
    json = ModelMethods.listToJson(json: json, property: "ingredients");
    json = ModelMethods.listToJson(json: json, property: "precautions");
    json["ids"] = jsonEncode(json["ids"].toJson());
    json["names"] = jsonEncode(json["names"].toJson());
    return json;
  }

  factory Product.fromFirestore(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data() as Map<String, dynamic>;

    data['id'] = documentSnapshot.reference.id;

    return _$ProductModelFromJson(data);
  }
}
