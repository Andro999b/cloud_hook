import 'dart:async';
import 'dart:convert';

import '../cryptojs.dart';
import '../jwplayer/jwplayer.dart';
import '../utils.dart';
import '../../scrapper/scrapper.dart';
import '../../utils.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:dio/dio.dart';

// rabbitstream ?

class MegacloudSourceLoader implements ContentMediaItemSourceLoader {
  static final _scriptRegExp1 = RegExp(
      r"case\s*0x[0-9a-f]+:(?![^;]*=partKey)\s*\w+\s*=\s*(\w+)\s*,\s*\w+\s*=\s*(\w+);");

  static final CachedKey<List<List<int>>> keys = CachedKey(
    url: "https://megacloud.tv/js/player/a/prod/e1-player.min.js",
    parse: _extractKeysFromScript,
  );

  final String url;
  final String? descriptionPrefix;

  const MegacloudSourceLoader({
    required this.url,
    this.descriptionPrefix,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final host = Uri.parse(url).authority;
    final id = url.substring(
      url.lastIndexOf("/") + 1,
      url.lastIndexOf("?"),
    );

    final res = await dio.getUri(
      Uri.http(host, "/embed-2/ajax/e-1/getSources", {
        "id": id,
      }),
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": url,
      }),
    );

    if (res.data["encrypted"] == true) {
      final (password, data) = extractPasswordAndData(
        await keys.fetch(),
        res.data["sources"],
      );

      final dataBytes = base64.decode(data);

      final decryptedSources = cryptoJSDecrypt(
        utf8.encode(password),
        dataBytes.sublist(8, 16),
        dataBytes.sublist(16),
      );

      return JWPlayer.fromJson(
        {
          ...res.data,
          "sources": json.decode(decryptedSources),
        },
        descriptionPrefix: descriptionPrefix,
      );
    }

    return JWPlayer.fromJson(res.data, descriptionPrefix: descriptionPrefix);
  }

  (String, String) extractPasswordAndData(
      List<List<int>> keyIndexes, String encrypted) {
    final chars = encrypted.split("");

    String password = "";
    int currentIndex = 0;
    for (final index in keyIndexes) {
      final start = index[0] + currentIndex;
      final end = start + index[1];

      for (var i = start; i < end; i++) {
        password += chars[i];
        chars[i] = "";
      }

      currentIndex += index[1];
    }

    return (password, chars.join());
  }

  static List<List<int>> _extractKeysFromScript(String data) {
    int extractKey(String value) {
      final key =
          RegExp(",$value=((?:0x)?([0-9a-fA-F]+))").firstMatch(data)?.group(1);

      if (key == null) {
        throw Exception("[megacloud] No key: $value found is script");
      }

      return int.parse(key.substring(2), radix: 16);
    }

    final firstScriptParts = _scriptRegExp1
        .allMatches(data)
        .map(
          (e) => [
            extractKey(e.group(1)!),
            extractKey(e.group(2)!),
          ],
        )
        .toList();

    return firstScriptParts;
  }
}
