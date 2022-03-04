import 'package:json_annotation/json_annotation.dart';

part 'mode.g.dart';

enum Modes { all, university }

@JsonSerializable()
class Mode {
  const Mode({required this.mode, this.university});

  final Modes mode;
  final String? university;

  factory Mode.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonCopy = Map.of(json);

    return _$ModeFromJson(jsonCopy);
  }
}
