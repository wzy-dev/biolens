// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: json['id'] as String,
      editedAt: json['editedAt'] as int,
      enabled: json['enabled'] as bool? ?? false,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'editedAt': instance.editedAt,
      'enabled': instance.enabled,
      'name': instance.name,
    };
