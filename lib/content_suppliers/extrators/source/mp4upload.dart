import 'dart:async';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:dio/dio.dart';

class MP4UploadSourceLoader implements ContentMediaItemSourceLoader {
  static const host = "www.mp4upload.com";
  // final RegExp _idRegExp = RegExp(r"\/(embed-|)(?<id>[A-Za-z0-9]*)");
  static final RegExp _srcUrl = RegExp(r'src:?\s+"(?<src>.*?(mp4|m3u8))"');

  final String url;
  final String? referer;
  final String descriptionPrefix;

  MP4UploadSourceLoader({
    required this.url,
    this.referer,
    this.descriptionPrefix = "",
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final res = await dio.get(url,
        options: Options(
          headers: {
            if (referer != null) "Referer": referer,
          },
        ));

    final link = _srcUrl.firstMatch(res.data)?.namedGroup("src");

    if (link == null) {
      return [];
    }

    return [
      SimpleContentMediaItemSource(
          description: "${descriptionPrefix}MP4Upload",
          link: Uri.parse(link),
          headers: {
            "Referer": url,
          })
    ];
  }
}
