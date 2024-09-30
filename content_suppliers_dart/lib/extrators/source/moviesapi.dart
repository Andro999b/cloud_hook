import 'dart:async';
import 'dart:convert';

import 'package:content_suppliers_dart/extrators/cryptojs.dart';
import 'package:content_suppliers_dart/extrators/jwplayer/jwplayer.dart';
import 'package:content_suppliers_dart/extrators/utils.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';

import 'multi_api_keys.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moviesapi.g.dart';

@JsonSerializable(createToJson: false)
class _CryptoJSParams {
  final String ct;
  final String iv;
  final String s;

  _CryptoJSParams({
    required this.ct,
    required this.iv,
    required this.s,
  });

  factory _CryptoJSParams.fromJson(Map<String, dynamic> json) =>
      _$CryptoJSParamsFromJson(json);
}

class MoviesapiSourceLoader implements ContentMediaItemSourceLoader {
  static const baseUrl = "https://moviesapi.club";
  static const iframeBaseUrl = "https://w1.moviesapi.club";

  static final _aesRegExp = RegExp(r"\s+=\s+'(?<aes>[^']+)'");
  static final _sourcesConfigRegExp = RegExp(r'sources:\s+(?<arr>[^\]]+\])');
  static final _tracksConfigRegExp = RegExp(r'tracks:\s+(?<arr>[^\]]+\])');

  final int tmdb;
  final int? episode;
  final int? season;

  MoviesapiSourceLoader({
    required this.tmdb,
    this.episode,
    this.season,
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    String url;

    if (episode == null) {
      url = "$baseUrl/movie/$tmdb";
    } else {
      url = "$baseUrl/tv/$tmdb-$season-$episode";
    }

    final iframe = await Scrapper(
      uri: Uri.parse(url),
      headers: {"Referer": baseUrl},
    ).scrap(
      Attribute.forScope("#frame2", "src"),
    );

    if (iframe == null || iframe.isEmpty) {
      logger.w("[moviesapi] iframe not found");
      return [];
    }

    return await _extractIframe(iframe, url);
  }

  Future<List<ContentMediaItemSource>> _extractIframe(
    String iframe,
    String url,
  ) async {
    final iframeRes = await dio.get(
      iframe,
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": url,
      }),
    );

    final page = iframeRes.data as String;
    final aesJsonStr = _aesRegExp.firstMatch(page)?.namedGroup("aes");

    if (aesJsonStr == null) {
      logger.w("[moviesapi] Encrypted code not found");
      return [];
    }

    final cryptoParams = _CryptoJSParams.fromJson(json.decode(aesJsonStr));

    final apiKeys = await MultiApiKeys.keys.fetch();

    if (apiKeys.chillx?.isEmpty ?? true) {
      logger.w("[moviesapi] chillx key not found");
      return [];
    }

    final script = json.decode(cryptoJSDecrypt64(
      utf8.encode(apiKeys.chillx!.first),
      hexToBytes(cryptoParams.s),
      cryptoParams.ct,
    ));

    final sources = _sourcesConfigRegExp.firstMatch(script)?.namedGroup("arr");
    final tracks = _tracksConfigRegExp.firstMatch(script)?.namedGroup("arr");

    if (sources == null) {
      logger.w("[moviesapi] sources url not found");
      return [];
    }

    final headers = {
      ...defaultHeaders,
      "Accept": "*/*",
      "Connection": "keep-alive",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "cross-site",
      "Origin": iframeBaseUrl,
      "Referer": iframeBaseUrl
    };

    return JWPlayer.fromConfig(
      JWPlayerConfig.fromJson({
        "sources": json.decode(sources),
        "tracks": tracks != null ? json.decode(tracks) : [],
      }),
      despriptionPrefix: "MoviesAPI",
      headers: headers,
    );
  }

  @override
  String toString() {
    return "MoviesapiSourceLoader(tmdb: $tmdb, episode: $episode, season: $season)";
  }
}
