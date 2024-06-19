import 'package:cloud_hook/content_suppliers/extrators/source/filemoon.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/vidplay.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:simple_rc4/simple_rc4.dart';

class VidSrcToSourceLoader {
  final rc4key = "WXrUARXb1aDLaZjI";
  final baseUrl = "https://vidsrc.to";
  final String imdb;
  final int? episode;
  final int? season;

  VidSrcToSourceLoader({
    required this.imdb,
    this.season,
    this.episode,
  });

  Future<List<ContentMediaItemSource>> call() async {
    String url;

    if (episode == null) {
      url = "$baseUrl/embed/movie/$imdb";
    } else {
      url = "$baseUrl/embed/tv/$imdb/$season/$episode";
    }

    final mediaId = await Scrapper(uri: url)
        .scrap(Attribute.forScope("ul.episodes li a", "data-id"));

    if (mediaId == null) {
      logger.w("[vidsrc.to] mediaId not found");
      return [];
    }

    final sourcesRes =
        await dio.get("$baseUrl/ajax/embed/episode/$mediaId/sources");

    final List<dynamic>? sources = sourcesRes.data["result"];

    if (sources == null) {
      logger.w("[vidsrc.to] sources not found");
      return [];
    }

    final Stream<ContentMediaItemSource> stream = Stream.fromIterable(sources)
        .asyncMap((source) async => switch (source["title"]) {
              "Vidplay" => await _extractVidplay(source["id"]),
              "Filemoon" => await _extractFilemoon(source["id"], url),
              _ => <ContentMediaItemSource>[]
            })
        .expand((element) => element);

    return await stream.toList();
  }

  Future<List<ContentMediaItemSource>> _extractVidplay(String id) async {
    final finalUrl = await _loadSource(id);

    if (finalUrl == null) {
      return [];
    }

    return VidPlaySourceLoader(url: finalUrl).call();
  }

  Future<List<ContentMediaItemSource>> _extractFilemoon(
      String id, String url) async {
    final finalUrl = await _loadSource(id);

    if (finalUrl == null) {
      return [];
    }

    return FileMoonSourceLoader(url: finalUrl, referer: url).call();
  }

  Future<String?> _loadSource(String id) async {
    final sourceRes = await dio.get("$baseUrl/ajax/embed/source/$id");
    final String? encUrl = sourceRes.data["result"]?["url"];

    if (encUrl == null) {
      logger.w("[vidsrc.to] encUrl not found for source $id");
      return null;
    }

    final rc4 = RC4(rc4key);
    return Uri.decodeComponent(rc4.decodeString(encUrl, true, false));
  }
}
