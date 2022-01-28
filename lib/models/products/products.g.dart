// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductModelFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      editedAt: json['editedAt'] as int,
      brand: json['brand'] as String,
      enabled: json['enabled'] as bool? ?? false,
      name: json['name'] as String,
      source: json['source'] as String?,
      picture: json['picture'] as String?,
      tagPicture: json['tagPicture'] as String?,
      cookbook: (json['cookbook'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      precautions: (json['precautions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ids: Ids.fromJson(json['ids'] as Map<String, dynamic>),
      names: Names.fromJson(json['names'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductModelToJson(Product instance) =>
    <String, dynamic>{
      'id': instance.id,
      'editedAt': instance.editedAt,
      'enabled': instance.enabled,
      'name': instance.name,
      'brand': instance.brand,
      'source': instance.source,
      'picture': instance.picture,
      'tagPicture': instance.tagPicture,
      'cookbook': instance.cookbook,
      'ingredients': instance.ingredients,
      'precautions': instance.precautions,
      'ids': instance.ids,
      'names': instance.names,
    };
