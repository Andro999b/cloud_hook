import 'dart:async';

import 'package:cloud_hook/content_suppliers/media_extrators/extractor.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

class UFDubMediaExtractor with MediaExtractor {
  static final _episodeUrlRegExp =
      // ignore: unnecessary_string_escapes
      RegExp("https:\/\/ufdub.com\/video\/VIDEOS\.php\?(.*?)'");

  @override
  Future<List<ContentMediaItem>> extract(String iframe) async {
    final iframeRes =
        await http.get(Uri.parse(iframe), headers: defaultHeaders);
    final iframeContent = iframeRes.body;

    final matches = _episodeUrlRegExp.allMatches(iframeContent);

    final episodesUrls =
        matches.map((e) => e.group(0)!).where((e) => !e.contains("Трейлер"));

    return episodesUrls.mapIndexed((index, e) {
      final uri = Uri.parse(e);
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
