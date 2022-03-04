// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mode _$ModeFromJson(Map<String, dynamic> json) => Mode(
      mode: $enumDecode(_$ModesEnumMap, json['mode']),
      university: json['university'] as String?,
    );

// Map<String, dynamic> _$ModeToJson(Mode instance) => <String, dynamic>{
//       'mode': _$ModesEnumMap[instance.mode],
//       'university': instance.university,
//     };

const _$ModesEnumMap = {
  Modes.all: 'all',
  Modes.university: 'university',
};
