import 'dart:convert';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:simple_rc4/simple_rc4.dart';

part 'vidplay.g.dart';

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
class Result {
  final List<Sources> sources;
  final List<Track> tracks;

  const Result({required this.sources, required this.tracks});

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}

class VidPlaySourceLoader {
  static final futokenRegExp = RegExp("k='(\\S+)'");
  final String url;

  const VidPlaySourceLoader({
    required this.url,
  });

  Future<List<ContentMediaItemSource>> call() async {
    final baseUrl = Uri.https(Uri.parse(url).authority).toString();

    String id = url.substring(0, url.indexOf("?"));
    id = id.substring(id.lastIndexOf("/") + 1);

    final encodedId = _encodeId(id, await _fetchKeys());
    final mediaUrl = await _callFutoken(encodedId, baseUrl, url);

    if (mediaUrl == null) {
      return [];
    }

    final mediaInfoRes = await dio.get(
      mediaUrl,
      options: Options(headers: {
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "X-Requested-With": "XMLHttpRequest",
        "Referer": url,
      }),
    );

    final result = Result.fromJson(mediaInfoRes.data["result"]);

    return [
      ...result.sources.map(
        (e) => SimpleContentMediaItemSource(
          description: "VidPlay",
          link: Uri.parse(e.file),
        ),
      ),
      ...result.tracks.map(
        (e) => SimpleContentMediaItemSource(
          kind: FileKind.subtitle,
          description: "[VidPlay]${e.label}",
          link: Uri.parse(e.file),
        ),
      ),
    ];
  }

  Future<List<String>> _fetchKeys() async {
    final res = await dio.get(
        "https://raw.githubusercontent.com/KillerDogeEmpire/vidplay-keys/keys/keys.json");

    return json.decode(res.data).cast<String>();
  }

  String _encodeId(String id, List<String> keys) {
    final [key1, key2] = keys;

    final chiper1 = RC4(key1);
    final chiper2 = RC4(key2);

    List<int> encodeId = chiper1.encodeBytes(utf8.encode(id));
    encodeId = chiper2.encodeBytes(encodeId);

    return base64.encode(encodeId).replaceAll("/", "_");
  }

  Future<String?> _callFutoken(String id, String baseUrl, String url) async {
    final futokenRes = await dio.get(
      "$baseUrl/futoken",
      options: Options(headers: {
        "Referer": url,
      }),
    );

    final script = futokenRes.data as String;
    final futoken = futokenRegExp.firstMatch(script)?.group(1);

    if (futoken == null) {
      logger.w("[vidplay] futoken not found");
      return null;
    }

    final a = [futoken];

    final idCodes = id.codeUnits;
    final futokenCodes = futoken.codeUnits;
    for (var i = 0; i < id.length; i++) {
      a.add((futokenCodes[i % futoken.length] + idCodes[i]).toString());
    }

    return "$baseUrl/mediainfo/${a.join(",")}?${url.substring(url.indexOf("?") + 1)}";
  }
}
