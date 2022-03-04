import 'package:biolens/models/shelf_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'universities.g.dart';

@JsonSerializable()
class University {
  // Main
  String id;
  int editedAt;
  bool? enabled;

  // Custom
  String name;
  List<String> products;

  University({
    required this.id,
    required this.editedAt,
    this.enabled = false,
    required this.name,
    required this.products,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);
    jsonCopy = ModelMethods.intToBool(json: jsonCopy, property: "enabled");
    jsonCopy = ModelMethods.jsonToList(json: jsonCopy, property: "products");
    return _$UniversityFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$UniversityToJson(this);
    json = ModelMethods.boolToInt(json: json, property: "enabled");
    json = ModelMethods.listToJson(json: json, property: "products");
    return json;
  }

  factory University.fromFirestore(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data() as Map<String, dynamic>;

    data['id'] = documentSnapshot.reference.id;

    return _$UniversityFromJson(data);
  }
}
