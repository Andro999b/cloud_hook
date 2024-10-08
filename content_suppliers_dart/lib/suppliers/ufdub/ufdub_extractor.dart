import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import '../../scrapper/scrapper.dart';
import '../../utils.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

class UFDubMediaExtractor implements ContentMediaItemLoader {
  static final _episodeUrlRegExp =
      // ignore: unnecessary_string_escapes
      RegExp("https:\/\/ufdub.com\/video\/VIDEOS\.php\?(.*?)'");

  final String iframe;

  UFDubMediaExtractor(this.iframe);

  @override
  Future<List<ContentMediaItem>> call() async {
    final iframeRes = await dio.get(
      iframe,
      options: Options(headers: defaultHeaders),
    );
    final iframeContent = iframeRes.data as String;

    final matches = _episodeUrlRegExp.allMatches(iframeContent);

    final episodesUrls =
        matches.map((e) => e.group(0)!).where((e) => !e.contains("Трейлер"));

    return episodesUrls.mapIndexed((index, e) {
      final uri = parseUri(e);
      return SimpleContentMediaItem(
        number: index,
        title: uri.queryParameters["Seriya"] ?? "",
        sources: [
          SimpleContentMediaItemSource(description: "UFDub", link: uri)
        ],
      );
    }).toList();
  }
}
