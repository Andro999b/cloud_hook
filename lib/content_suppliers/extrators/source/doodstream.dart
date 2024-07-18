import 'dart:async';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';

class DoodStreamSourceLoader implements ContentMediaItemSourceLoader {
  static const doodHost = "d0000d.com";
  static const _rndString = "d96ZdcNq9N";
  static final _md5passRegExp = RegExp(r"/pass_md5/(?<pass>[^']*)");

  final String url;
  final String referer;
  final String despriptionPrefix;

  DoodStreamSourceLoader({
    required this.url,
    required this.referer,
    this.despriptionPrefix = "",
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final uri = Uri.parse(url).replace(host: doodHost);

    final iframeRes = await dio.getUri(
      uri,
      options: Options(headers: {...defaultHeaders}),
    );

    final md5pass =
        _md5passRegExp.firstMatch(iframeRes.data)?.namedGroup("pass");

    if (md5pass == null) {
      logger.w("[doodstream] md5pass not found");
      return [];
    }

    final mediaLinkRes = await dio.getUri(
      Uri.https(doodHost, "/pass_md5/$md5pass"),
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": uri.toString(),
      }),
    );

    final mediaUrl = "${mediaLinkRes.data}$_rndString?token=$md5pass";

    return [
      SimpleContentMediaItemSource(
        description: "${despriptionPrefix}doodstream",
        link: parseUri(mediaUrl),
        headers: {"Referer": uri.toString()},
      )
    ];
  }

  @override
  String toString() =>
      "DoodStreamSourceLoader(url: $url, referer: $referer, despriptionPrefix: $despriptionPrefix)";
}
