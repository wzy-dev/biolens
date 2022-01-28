// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ids.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ids _$IdsFromJson(Map<String, dynamic> json) => Ids(
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      indications: (json['indications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$IdsToJson(Ids instance) => <String, dynamic>{
      'category': instance.category,
      'subCategory': instance.subCategory,
      'indications': instance.indications,
      'tags': instance.tags,
    };
