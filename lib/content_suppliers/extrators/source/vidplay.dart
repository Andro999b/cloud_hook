import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:simple_rc4/simple_rc4.dart';

class VidPlaySourceLoader implements ContentMediaItemSourceLoader {
  static final futokenRegExp = RegExp(r"k='(?<futoken>\S+)'");
  static final wafDetectorRegExp =
      RegExp(r"_a = '(?<a>[a-z0-9]+)',\s+_b = '(?<b>[a-z0-9]+)'");

  final String url;
  final String despriptionPrefix;

  const VidPlaySourceLoader({
    required this.url,
    this.despriptionPrefix = "",
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    final host = parseUri(url).authority;

    String id = url.substring(0, url.indexOf("?"));
    id = id.substring(id.lastIndexOf("/") + 1);

    final encodedId = _encodeId(id, await _fetchKeys());
    final mediaUrl = await _callFutoken(encodedId, host, url);

    if (mediaUrl == null) {
      return [];
    }

    final mediaInfoRes = await dio.get(
      mediaUrl,
      options: Options(headers: {
        ...defaultHeaders,
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "X-Requested-With": "XMLHttpRequest",
        "Referer": url,
        "Host": host,
      }),
    );

    if (mediaInfoRes.data["result"] is int) {
      logger.w(
          "[vidplay] Invalid media response: ${mediaInfoRes.data["result"]}. "
          "Probably keys expired");
      return [];
    }

    return JWPlayer.fromJson(
      mediaInfoRes.data["result"],
      despriptionPrefix: "${despriptionPrefix}VidPlay",
    );
  }

  Future<List<String>> _fetchKeys() async {
    // final apiKeys = await MultiApiKeys.fetch();

    // return apiKeys.vidplay ?? [];
    final res = await dio.get(
      // "https://raw.githubusercontent.com/Ciarands/vidsrc-keys/main/keys.json",
      "https://raw.githubusercontent.com/Inside4ndroid/vidkey-js/main/keys.json",
    );

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

  Future<String?> _callFutoken(String id, String host, String url) async {
    const baseUrl = "http://$cloudWallIp";
    final futokenRes = await dio.get(
      "$baseUrl/futoken",
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": url,
        "Host": host,
      }),
    );

    final page = futokenRes.data as String;
    final futoken = futokenRegExp.firstMatch(page)?.namedGroup("futoken");

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

  @override
  String toString() {
    return "VidPlaySourceLoader(url: $url)";
  }
}
