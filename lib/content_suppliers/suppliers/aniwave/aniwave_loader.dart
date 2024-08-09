import 'dart:async';

import 'package:cloud_hook/content_suppliers/extrators/source/vidsrcto.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/aniwave/aniwave_vrf.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aniwave_loader.g.dart';

class AniWaveMediaItemLoader implements ContentMediaItemLoader {
  final String host;
  final String mediaId;

  AniWaveMediaItemLoader(this.host, this.mediaId);

  @override
  FutureOr<List<ContentMediaItem>> call() async {
    final vrf = await aniwaveVRF(mediaId);

    final episodesRes = await dio.get(
      "https://$host/ajax/episode/list/$mediaId?vrf=$vrf",
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": "https://$host",
      }),
    );

    final episodes = await srapEpisodeslist(episodesRes.data["result"]);

    return episodes
        .mapIndexed((i, e) => AsyncContentMediaItem(
              number: i,
              title: "${e.number} episode",
              sourcesLoader: sourceLoader(e),
            ))
        .toList();
  }

  FutureOr<List<Episode>> srapEpisodeslist(String text) async {
    final episodesJson = await Scrapper.scrapFragment(
      text,
      ".body",
      Scope(
        scope: ".episodes",
        item: Iterate(
          itemScope: "li a",
          item: SelectorsToMap({
            "id": Attribute("data-ids"),
            "number": Attribute("data-num"),
          }),
        ),
      ),
    );

    return episodesJson?.map(Episode.fromJson).toList() ?? [];
  }

  AniWaveSourceLoader sourceLoader(Episode ep) {
    return AniWaveSourceLoader(host, ep.id);
  }
}

class AniWaveSourceLoader implements ContentMediaItemSourceLoader {
  final String host;
  final String id;

  AniWaveSourceLoader(this.host, this.id);

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final vrf = await aniwaveVRF(id);

    final serversRes = await dio.get(
      "https://$host/ajax/server/list/$id?vrf=$vrf",
      options: Options(headers: {...defaultHeaders}),
    );

    final servers = await scrapServers(serversRes.data["result"]);

    return AggSourceLoader(
      servers
          .mapIndexed(
            (idx, s) => AniWaveServerSorceLoader(host, s),
          )
          .toList(),
    ).call();
  }

  Future<List<Server>> scrapServers(String text) async {
    final serversJson = await Scrapper.scrapFragment(
      text,
      ".servers",
      Flatten([
        Iterate(
          itemScope: "div[data-type='softsub'] li",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("S-SUB")
          }),
        ),
        Iterate(
          itemScope: "div[data-type='sub'] li",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("SUB")
          }),
        ),
        Iterate(
          itemScope: "div[data-type='dub'] li",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("DUB")
          }),
        ),
      ]),
    );

    return serversJson?.map(Server.fromJson).toList() ?? [];
  }
}

class AniWaveServerSorceLoader
    with VidSrcToServerMixin
    implements ContentMediaItemSourceLoader {
  final String host;
  final Server server;

  AniWaveServerSorceLoader(this.host, this.server);

  @override
  FutureOr<List<ContentMediaItemSource>> call() {
    final prefix = "[${server.prefix}] ${server.title}";
    return extractServer(
      server.title,
      server.id,
      "https://$host",
      prefix,
    );
  }

  @override
  Future<String?> loadSource(String id) async {
    final vrf = await aniwaveVRF(id);

    final serverRes = await dio.get(
      "https://$host/ajax/server/$id?vrf=$vrf",
      options: Options(headers: {...defaultHeaders}),
    );

    final String? encUrl = serverRes.data["result"]?["url"];

    if (encUrl == null) {
      logger.w("[$host] encUrl not found for source $id");
      return null;
    }

    return await aniwaveDecryptURL(encUrl);
  }
}

@JsonSerializable(createToJson: false)
class Episode {
  final String id;
  final String number;

  Episode(this.id, this.number);

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
}

@JsonSerializable(createToJson: false)
class Server {
  final String id;
  final String title;
  final String prefix;

  Server(this.id, this.title, this.prefix);

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
}
