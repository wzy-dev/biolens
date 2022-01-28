import 'package:biolens/models/mydatabase.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ids.g.dart';

@JsonSerializable()
class Ids {
  const Ids(
      {required this.category,
      required this.subCategory,
      this.indications = const [],
      this.tags = const []});

  final String category;
  final String subCategory;
  final List<String> indications;
  final List<String> tags;

  factory Ids.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);
    return _$IdsFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$IdsToJson(this);
    json = ModelMethods.listToJson(json: json, property: "indications");
    json = ModelMethods.listToJson(json: json, property: "tags");
    return json;
  }
}
