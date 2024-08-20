import 'package:cloud_hook/content_suppliers/extrators/source/filemoon.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/mp4upload.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/vidplay.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';

class VidSrcToSourceLoader
    with VidSrcToServerMixin
    implements ContentMediaItemSourceLoader {
  final host = "vidsrc2.to";
  final String imdb;
  final int? episode;
  final int? season;
  late final String baseUrl = "https://$host";

  VidSrcToSourceLoader({
    required this.imdb,
    this.season,
    this.episode,
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    String url;

    if (episode == null) {
      url = "$baseUrl/embed/movie/$imdb";
    } else {
      url = "$baseUrl/embed/tv/$imdb/$season/$episode";
    }

    final keys = await MultiApiKeys.fetch();

    final mediaId = await Scrapper(
      uri: Uri.parse(url),
      headers: {...defaultHeaders},
    ).scrap(Attribute.forScope("ul.episodes li a", "data-id"));

    if (mediaId == null) {
      logger.w("[vidsrc.to] mediaId not found");
      return [];
    }

    final sourcesRes = await dio.get(
      "$baseUrl/ajax/embed/episode/$mediaId/sources?token="
      "${_encrypt(mediaId, keys.vidsrcto!)}",
      options: Options(
        headers: {...defaultHeaders},
      ),
    );

    final List<dynamic>? sources = sourcesRes.data["result"];

    if (sources == null) {
      logger.w("[vidsrc.to] sources not found");
      return [];
    }

    final Stream<ContentMediaItemSource> stream = Stream.fromIterable(sources)
        .asyncMap((source) => extractServer(
              source["title"],
              source["id"]!,
              url,
            ))
        .expand((element) => element);

    return await stream.toList();
  }

  @override
  Future<String?> loadSource(String id) async {
    final keys = await MultiApiKeys.fetch();

    final sourceRes = await dio.get(
        "$baseUrl/ajax/embed/source/$id?token="
        "${_encrypt(id, keys.vidsrcto!)}",
        options: Options(
          headers: {
            ...defaultHeaders,
            "Host": host,
          },
        ));
    final String? encUrl = sourceRes.data["result"]?["url"];

    if (encUrl == null) {
      logger.w("[vidsrc.to] encUrl not found for source $id");
      return null;
    }

    return _decode(encUrl, keys.vidsrcto!);
  }

  @override
  String toString() {
    return "VidSrcToSourceLoader(imdb: $imdb, episode: $episode, season: $season)";
  }

  String _encrypt(String data, List<KeyOps> ops) {
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
}

mixin VidSrcToServerMixin {
  Future<String?> loadSource(String id);

  Future<List<ContentMediaItemSource>> extractServer(
      String serverName, String serverId, String referer,
      [String? descriptionPrefix]) async {
    try {
      return switch (serverName.toLowerCase()) {
        "server 1" ||
        "vidplay" ||
        "vidstream" ||
        "megaf" ||
        "f2cloud" ||
        "server 1" =>
          await _extractVidplay(serverId, descriptionPrefix),
        "server 2" ||
        "filemoon" ||
        "moonf" =>
          await _extractFilemoon(serverId, referer, descriptionPrefix),
        "mp4upload" ||
        "mp4u" =>
          await _extractMp4upload(serverId, descriptionPrefix),
        _ => <ContentMediaItemSource>[]
      };
    } catch (error, stackTrace) {
      logger.w("[vidsrcto] server $serverName failed. Error: $error",
          stackTrace: stackTrace);
      return <ContentMediaItemSource>[];
    }
  }

  Future<List<ContentMediaItemSource>> _extractVidplay(
    String serverId,
    String? descriptionPrefix,
  ) async {
    final finalUrl = await loadSource(serverId);

    if (finalUrl == null) {
      return [];
    }

    return VidPlaySourceLoader(
      url: finalUrl,
      despriptionPrefix: descriptionPrefix,
    ).call();
  }

  Future<List<ContentMediaItemSource>> _extractFilemoon(
    String serverId,
    String url,
    String? descriptionPrefix,
  ) async {
    final finalUrl = await loadSource(serverId);

    if (finalUrl == null) {
      return [];
    }

    return FileMoonSourceLoader(
      url: finalUrl,
      referer: url,
      despriptionPrefix: descriptionPrefix,
    ).call();
  }

  Future<List<ContentMediaItemSource>> _extractMp4upload(
    String serverId,
    String? descriptionPrefix,
  ) async {
    final finalUrl = await loadSource(serverId);

    if (finalUrl == null) {
      return [];
    }

    return MP4UploadSourceLoader(
      url: finalUrl,
      descriptionPrefix: descriptionPrefix,
    ).call();
  }
}
