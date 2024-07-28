import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:simple_rc4/simple_rc4.dart';

class VidPlaySourceLoader implements ContentMediaItemSourceLoader {
  final String url;
  final String? despriptionPrefix;

  const VidPlaySourceLoader({
    required this.url,
    this.despriptionPrefix,
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    final uri = parseUri(url);

    final host = uri.authority;
    final keys = await _fetchKeys();

    final id = _extractId(url);
    final endcodedId = _encode(_extractId(url), keys[0]);
    final h = _encode(id, keys[1]);

    final mediaInfoUri = Uri.https(host, "/mediainfo/$endcodedId", {
      ...uri.queryParameters,
      "h": h,
    });

    final mediaInfoRes = await dio.getUri(mediaInfoUri);

    if (mediaInfoRes.data["result"] is int) {
      logger.w("[VidPlay] mediaInfo not found. Keys maybe expired");
      return [];
    }

    final decodedResult = _decode(mediaInfoRes.data["result"], keys[2]);
    final mediaInfo = json.decode(decodedResult) as Map<String, dynamic>;

    return JWPlayer.fromJson(
      mediaInfo,
      descriptionPrefix: despriptionPrefix ?? "VidPlay",
    );
  }

  Future<List<String>> _fetchKeys() async {
    final apiKeys = await MultiApiKeys.fetch();

    return apiKeys.vidplay ?? [];
    //   "https://raw.githubusercontent.com/Ciarands/vidsrc-keys/main/keys.json",
    //   "https://raw.githubusercontent.com/Inside4ndroid/vidkey-js/main/keys.json",
  }

  String _encode(String data, String key) {
    final cipher = RC4(key);

    var encoded = utf8.encode(data).toList();
    encoded = cipher.encodeBytes(encoded);

    return base64Url.encode(encoded);
  }

  String _decode(String data, String key) {
    final cipher = RC4(key);

    final decoded = cipher.decodeBytes(base64.decode(data));

    return Uri.decodeComponent(decoded);
  }

  String _extractId(String url) {
    String str = url.substring(0, url.indexOf("?"));
    str = str.substring(str.lastIndexOf("/") + 1);
    return str;
  }

  @override
  String toString() =>
      "VidPlaySourceLoader(url: $url, despriptionPrefix: $despriptionPrefix)";
}
