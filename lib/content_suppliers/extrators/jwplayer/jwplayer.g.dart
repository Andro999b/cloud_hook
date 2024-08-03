// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwplayer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      file: json['file'] as String,
      kind: json['kind'] as String,
      label: json['label'] as String?,
    );

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
      file: json['file'] as String,
      label: json['label'] as String?,
    );

JWPlayerConfig _$JWPlayerConfigFromJson(Map<String, dynamic> json) =>
    JWPlayerConfig(
      sources: (json['sources'] as List<dynamic>)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
