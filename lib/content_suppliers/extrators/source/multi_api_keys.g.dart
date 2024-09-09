// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_api_keys.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiKeys _$ApiKeysFromJson(Map<String, dynamic> json) => ApiKeys(
      chillx:
          (json['chillx'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

KeyOps _$KeyOpsFromJson(Map<String, dynamic> json) => KeyOps(
      sequence: (json['sequence'] as num).toInt(),
      method: json['method'] as String,
      keys: (json['keys'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
