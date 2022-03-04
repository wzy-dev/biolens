// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation(
      id: json['id'] as String,
      editedAt: json['editedAt'] as int,
      enabled: json['enabled'] as bool? ?? false,
      university: json['university'] as String,
      note: json['note'] as String,
      product: json['product'] as String,
    );

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'editedAt': instance.editedAt,
      'enabled': instance.enabled,
      'university': instance.university,
      'note': instance.note,
      'product': instance.product,
    };
