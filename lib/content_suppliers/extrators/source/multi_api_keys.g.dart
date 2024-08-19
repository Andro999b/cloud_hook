// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_api_keys.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiKeys _$ApiKeysFromJson(Map<String, dynamic> json) => ApiKeys(
      chillx:
          (json['chillx'] as List<dynamic>?)?.map((e) => e as String).toList(),
      vidplay: (json['vidplay'] as List<dynamic>?)
          ?.map((e) => KeyOps.fromJson(e as Map<String, dynamic>))
          .toList(),
      aniwave: (json['aniwave'] as List<dynamic>?)
          ?.map((e) => KeyOps.fromJson(e as Map<String, dynamic>))
          .toList(),
      cinezone: (json['cinezone'] as List<dynamic>?)
          ?.map((e) => KeyOps.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

KeyOps _$KeyOpsFromJson(Map<String, dynamic> json) => KeyOps(
      sequence: (json['sequence'] as num).toInt(),
      method: json['method'] as String,
      keys: (json['keys'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
