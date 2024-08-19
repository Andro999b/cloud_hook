import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';

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
    final keys = await MultiApiKeys.fetch();

    final id = _extractId(url);
    final endcodedId = _encode(_extractId(url), keys.vidplay!);

    final hKey = keys.vidplay!.firstWhere((op) => op.method == "h");
    final h = runRC4EncryptOp(id, hKey.keys![0]);

    final mediaInfoUri = Uri.https(host, "/mediainfo/$endcodedId", {
      ...uri.queryParameters,
      "h": h,
    });

    final mediaInfoRes = await dio.getUri(mediaInfoUri);

    if (mediaInfoRes.data["result"] is int) {
      logger.w("[VidPlay] mediaInfo not found. Keys maybe expired");
      return [];
    }

    final decodedResult = _decode(mediaInfoRes.data["result"], keys.vidplay!);
    final mediaInfo = json.decode(decodedResult) as Map<String, dynamic>;

    return JWPlayer.fromJson(
      mediaInfo,
      descriptionPrefix: despriptionPrefix ?? "VidPlay",
    );
  }

  String _encode(String data, List<KeyOps> ops) {
    String out = data;

    for (var op in ops) {
      out = op.encrypt(out);
    }

    return out;
  }

  String _decode(String data, List<KeyOps> ops) {
    String out = data;

    for (var op in ops.reversed) {
      out = op.decrypt(out);
    }

    return Uri.decodeComponent(out);
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
