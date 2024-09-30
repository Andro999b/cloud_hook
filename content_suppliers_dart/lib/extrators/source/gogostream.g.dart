// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gogostream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinksConfig _$LinksConfigFromJson(Map<String, dynamic> json) => LinksConfig(
      source: (json['source'] as List<dynamic>)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      sourceBk: (json['source_bk'] as List<dynamic>)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      track: (json['track'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
