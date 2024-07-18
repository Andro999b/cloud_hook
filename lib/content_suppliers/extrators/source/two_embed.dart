import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';

class TwoEmbedSourceLoader implements ContentMediaItemSourceLoader {
  static final _fileRegExp = RegExp("file:\\s?['\"](?<file>.+)['\"]");
  final playerBaseUrl = "https://uqloads.xyz/e";
  final baseUrl = "https://www.2embed.cc";
  final String imdb;

  final int? episode;
  final int? season;
  final String despriptionPrefix;

  TwoEmbedSourceLoader({
    required this.imdb,
    this.season,
    this.episode,
    this.despriptionPrefix = "",
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    String uri;

    if (episode == null) {
      uri = "$baseUrl/embed/$imdb";
    } else {
      uri = "$baseUrl/embedtv/$imdb&s=$season&e=$episode";
    }

    final scrapper = Scrapper(uri: uri);

    final iframe = await scrapper
        .scrap(Attribute.forScope("iframe#iframesrc", "data-src"));

    if (iframe == null) {
      logger.w("[2embed] iframe not found");
      return [];
    }

    final iframeUri = parseUri(iframe);
    final id = iframeUri.queryParameters["id"];
    final ref = iframeUri.host;

    if (id == null) {
      logger.w("[2embed] id not found in iframe: $iframe");
      return [];
    }

    // jwplayer
    final playerRes = await dio.get(
      "$playerBaseUrl/$id",
      options: Options(
        headers: {"Referer": ref},
      ),
    );

    final match = _fileRegExp.firstMatch(playerRes.data);
    final file = match?.namedGroup("file");

    if (file == null) {
      logger.w("[2embed] file not found in player");
      return [];
    }

    return [
      SimpleContentMediaItemSource(
        link: parseUri(file),
        description: "${despriptionPrefix}2embed",
      )
    ];
  }

  @override
  String toString() =>
      "TwoEmbedSourceLoader(imdb: $imdb, episode: $episode, season: $season, despriptionPrefix: $despriptionPrefix)";
}
