// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vidplay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      file: json['file'] as String,
      label: json['label'] as String?,
      kind: json['kind'] as String,
    );

Sources _$SourcesFromJson(Map<String, dynamic> json) => Sources(
      file: json['file'] as String,
    );

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      sources: (json['sources'] as List<dynamic>)
          .map((e) => Sources.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
