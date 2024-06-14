import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:simple_rc4/simple_rc4.dart';

class VidPlaySourceLoader {
  static final futokenRegExp = RegExp(r"k='(?<futoken>\S+)'");
  static final wafDetectorRegExp =
      RegExp(r"_a = '(?<a>[a-z0-9]+)',\s+_b = '(?<b>[a-z0-9]+)'");

  // static final dio = Dio();
  // ..interceptors.add(LogInterceptor(
  //   requestBody: true,
  //   responseBody: false,
  // logPrint: logger.i,
  // ));

  final String url;

  static String _lastWafCookie = "";

  const VidPlaySourceLoader({
    required this.url,
  });

  Future<List<ContentMediaItemSource>> call() async {
    final host = Uri.parse(url).authority;
    final baseUrl = Uri.https(host).toString();

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
        ...defaultHeaders,
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "X-Requested-With": "XMLHttpRequest",
        "Referer": url,
        "Cookie": _lastWafCookie,
        "Host": host,
      }),
    );

    return JWPlayer.fromJson(
      mediaInfoRes.data["result"],
      despriptionPrefix: "VidPlay",
    );
  }

  Future<List<String>> _fetchKeys() async {
    // final apiKeys = await MultiApiKeys.fetch();

    // return apiKeys.vidplay ?? [];
    final res = await dio.get(
      "https://raw.githubusercontent.com/Ciarands/vidsrc-keys/main/keys.json",
    );

    return json.decode(res.data).cast<String>();
  }

  Future<String> _fetchWAFToken() async {
    final res = await dio.get(
        "https://gist.githubusercontent.com/Andro999b/560835a26bdabdee507d653d414b2d6e/raw/b4969665789732546cd28fed75a77fa34c555df6/vidplay-waf-token.txt");

    return res.data;
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
    final futokenRes = await _fetchFutoken(baseUrl, url);

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

  Future<Response<dynamic>> _fetchFutoken(String baseUrl, String url) async {
    var res = await dio.get(
      "$baseUrl/futoken",
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": url,
        "Cookie": _lastWafCookie,
      }),
    );

    var page = res.data;

    final wafMatch = wafDetectorRegExp.firstMatch(page);
    if (wafMatch != null) {
      // sove js chellange
      final a = wafMatch.namedGroup("a")!;
      final b = wafMatch.namedGroup("b")!;
      final k = await _fetchWAFToken();

      var jscheck = "";
      for (var i = 0; i < k.length; i++) {
        jscheck += k[i] + a[i] + b[i];
      }

      res = await dio.get(
        "$url&__jscheck=$jscheck",
        options: Options(headers: {
          ...defaultHeaders,
        }),
      );

      _lastWafCookie = res.headers["set-cookie"]?.first.split(";").first ?? "";

      res = await dio.get(
        "$baseUrl/futoken",
        options: Options(headers: {
          ...defaultHeaders,
          "Referer": url,
          "Cookie": _lastWafCookie,
        }),
      );
    }

    return res;
  }
}
