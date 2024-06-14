import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jwplayer.g.dart';

@immutable
@JsonSerializable(createToJson: false)
class Track {
  final String file;
  final String? label;
  final String kind;

  const Track({required this.file, required this.label, required this.kind});

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}

@immutable
@JsonSerializable(createToJson: false)
class Sources {
  final String file;

  const Sources({required this.file});

  factory Sources.fromJson(Map<String, dynamic> json) =>
      _$SourcesFromJson(json);
}

@immutable
@JsonSerializable(createToJson: false)
class JWPlayerConfig {
  final List<Sources> sources;
  final List<Track> tracks;

  const JWPlayerConfig({required this.sources, required this.tracks});

  factory JWPlayerConfig.fromJson(Map<String, dynamic> json) =>
      _$JWPlayerConfigFromJson(json);
}

class JWPlayer {
  JWPlayer._();

  static List<ContentMediaItemSource> fromJson(
    Map<String, dynamic> json, {
    String despriptionPrefix = "JWPlayer",
    Map<String, String>? headers,
  }) {
    final config = JWPlayerConfig.fromJson(json);
    return fromConfig(
      config,
      despriptionPrefix: despriptionPrefix,
      headers: headers,
    );
  }

  static List<ContentMediaItemSource> fromConfig(
    JWPlayerConfig config, {
    String despriptionPrefix = "JWPlayer",
    Map<String, String>? headers,
  }) {
    return [
      ...config.sources.map(
        (e) => SimpleContentMediaItemSource(
          description: despriptionPrefix,
          link: Uri.parse(e.file),
          headers: headers,
        ),
      ),
      ...config.tracks
          .where((t) => t.kind == "captions" || t.kind == "subtitles")
          .map(
            (e) => SimpleContentMediaItemSource(
              kind: FileKind.subtitle,
              description: "[$despriptionPrefix] ${e.label}",
              link: Uri.parse(e.file),
              headers: headers,
            ),
          ),
    ];
  }
}
