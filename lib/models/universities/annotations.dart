import 'package:biolens/models/shelf_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'annotations.g.dart';

@JsonSerializable()
class Annotation {
  // Main
  String id;
  int editedAt;
  bool? enabled;

  // Custom
  String university;
  String note;
  String product;

  Annotation({
    required this.id,
    required this.editedAt,
    this.enabled = false,
    required this.university,
    required this.note,
    required this.product,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);
    jsonCopy = ModelMethods.intToBool(json: jsonCopy, property: "enabled");
    return _$AnnotationFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$AnnotationToJson(this);
    json = ModelMethods.boolToInt(json: json, property: "enabled");
    return json;
  }

  factory Annotation.fromFirestore(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data() as Map<String, dynamic>;

    data['university'] = documentSnapshot.reference.parent.parent!.id;
    data['id'] = documentSnapshot.reference.id;

    return _$AnnotationFromJson(data);
  }
}
