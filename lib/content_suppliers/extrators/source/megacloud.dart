import 'dart:async';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:dio/dio.dart';

class MegacloudSourceLoader implements ContentMediaItemSourceLoader {
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

    return JWPlayer.fromJson(res.data, descriptionPrefix: descriptionPrefix);
  }
}
