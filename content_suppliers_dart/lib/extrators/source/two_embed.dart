import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'package:js_unpack/js_unpack.dart';

class TwoEmbedSourceLoader implements ContentMediaItemSourceLoader {
  static final _fileRegExp = RegExp("file:\\s?['\"](?<file>.+)['\"]");
  final playerHost = "uqloads.xyz";
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
    String url;

    if (episode == null) {
      url = "$baseUrl/embed/$imdb";
    } else {
      url = "$baseUrl/embedtv/$imdb&s=$season&e=$episode";
    }

    final iframe = await Scrapper(uri: Uri.parse(url))
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

    final scrapper = Scrapper(
      uri: Uri.https(playerHost, "/e/$id"),
      headers: {
        "Referer": ref,
      },
    );

    final packedScript = await scrapper.scrap(Filter(
          Iterate(itemScope: "script", item: TextSelector()),
          filter: (script) => script.startsWith("eval("),
        )) ??
        [];

    if (packedScript.isEmpty) {
      logger.w("[2embed] packedScript not found in player");
      return [];
    }

    final unpackedScript = JsUnpack(packedScript.first).unpack();

    final match = _fileRegExp.firstMatch(unpackedScript);
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
