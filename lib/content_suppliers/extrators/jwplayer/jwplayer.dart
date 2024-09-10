import 'dart:async';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jwplayer.g.dart';

@immutable
@JsonSerializable(createToJson: false)
class Track {
  final String file;
  final String kind;
  final String? label;

  const Track({
    required this.file,
    required this.kind,
    this.label,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}

@immutable
@JsonSerializable(createToJson: false)
class Source {
  final String file;
  final String? label;

  const Source({
    required this.file,
    this.label,
  });

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);
}

@immutable
@JsonSerializable(createToJson: false)
class JWPlayerConfig {
  final List<Source> sources;
  final List<Track> tracks;

  const JWPlayerConfig({required this.sources, required this.tracks});

  factory JWPlayerConfig.fromJson(Map<String, dynamic> json) =>
      _$JWPlayerConfigFromJson(json);
}

class JWPlayer {
  JWPlayer._();

  static List<ContentMediaItemSource> fromJson(
    Map<String, dynamic> json, {
    String? descriptionPrefix,
    Map<String, String>? headers,
  }) {
    final config = JWPlayerConfig.fromJson(json);
    return fromConfig(
      config,
      despriptionPrefix: descriptionPrefix,
      headers: headers,
    );
  }

  static List<ContentMediaItemSource> fromConfig(
    JWPlayerConfig config, {
    String? despriptionPrefix,
    Map<String, String>? headers,
  }) {
    return [
      ...config.sources.mapIndexed(
        (idx, e) => SimpleContentMediaItemSource(
          description:
              "${despriptionPrefix ?? ""} ${idx + 1}. ${e.label ?? ""}",
          link: parseUri(e.file),
          headers: headers,
        ),
      ),
      ...config.tracks
          .where((t) => t.kind == "captions" || t.kind == "subtitles")
          .mapIndexed(
            (idx, e) => SimpleContentMediaItemSource(
              kind: FileKind.subtitle,
              description:
                  "${despriptionPrefix ?? ""} ${idx + 1}. ${e.label ?? ""}",
              link: parseUri(e.file),
              headers: headers,
            ),
          ),
    ];
  }
}

class JWPlayerSingleFileSourceLoader implements ContentMediaItemSourceLoader {
  static final _fileRegExp = RegExp("file:\\s?['\"](?<file>[^\"]+)['\"]");

  final String url;
  final String? referer;
  final String descriptionPrefix;

  JWPlayerSingleFileSourceLoader({
    required this.url,
    required this.referer,
    this.descriptionPrefix = "",
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final res = await dio.get(
      url,
      options: Options(
        headers: {...defaultHeaders, "Referer": referer},
      ),
    );

    return lookupFile(res.data, descriptionPrefix: descriptionPrefix);
  }

  static List<ContentMediaItemSource> lookupFile(
    String script, {
    String? descriptionPrefix,
  }) {
    final file = _fileRegExp.firstMatch(script)?.namedGroup("file");

    if (file == null) {
      logger.w("[jwplayer] sources url not found");
      return [];
    }

    return [
      SimpleContentMediaItemSource(
        description: descriptionPrefix ?? "jwplayer",
        link: parseUri(file),
      )
    ];
  }

  @override
  String toString() =>
      "JWPlayerSingleFileSourceLoader(url: $url, referr: $referer, descriptionPrefix: $descriptionPrefix)";
}
