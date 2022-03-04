// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'universities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

University _$UniversityFromJson(Map<String, dynamic> json) => University(
      id: json['id'] as String,
      editedAt: json['editedAt'] as int,
      enabled: json['enabled'] as bool? ?? false,
      name: json['name'] as String,
      products:
          (json['products'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UniversityToJson(University instance) =>
    <String, dynamic>{
      'id': instance.id,
      'editedAt': instance.editedAt,
      'enabled': instance.enabled,
      'name': instance.name,
      'products': instance.products,
    };
