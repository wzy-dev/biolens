import 'package:biolens/models/mydatabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tags.g.dart';

@JsonSerializable()
class Tag {
  // Main
  String id;
  int editedAt;
  bool? enabled;

  // Custom
  String name;

  Tag({
    required this.id,
    required this.editedAt,
    this.enabled = false,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);
    jsonCopy = ModelMethods.intToBool(json: jsonCopy, property: "enabled");
    return _$TagFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$TagToJson(this);
    json = ModelMethods.boolToInt(json: json, property: "enabled");
    return json;
  }

  factory Tag.fromFirestore(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data() as Map<String, dynamic>;

    data['id'] = documentSnapshot.reference.id;

    return _$TagFromJson(data);
  }
}
