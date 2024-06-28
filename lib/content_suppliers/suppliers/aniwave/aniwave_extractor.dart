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

part 'aniwave_extractor.g.dart';

class AniWaveExtractor implements ContentMediaItemLoader {
  final String address;
  final String host;
  final String mediaId;

  AniWaveExtractor(this.address, this.host, this.mediaId);

  @override
  FutureOr<List<ContentMediaItem>> call() async {
    final vrf = aniwaveVRF(mediaId);

    final episodesRes = await dio.get(
      "http://$address/ajax/episode/list/$mediaId?vrf=$vrf",
      options: Options(headers: {
        ...defaultHeaders,
        "Host": host,
        "Referer": "https://$host",
      }),
    );

    final episodesJson = await Scrapper.scrapFragment(
      episodesRes.data["result"],
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

    if (episodesJson == null) {
      return [];
    }

    return episodesJson
        .mapIndexed((i, e) => AsyncContentMediaItem(
              number: i,
              title: "${e["number"]} episode",
              sourcesLoader: AniWaveSorceLoader(
                address,
                host,
                e["id"] as String,
              ),
            ))
        .toList();
  }
}

@JsonSerializable(createToJson: false)
class Server {
  final String id;
  final String title;
  final String prefix;

  Server(this.id, this.title, this.prefix);

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
}

class AniWaveSorceLoader implements ContentMediaItemSourceLoader {
  final String address;
  final String host;
  final String id;

  AniWaveSorceLoader(this.address, this.host, this.id);

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final vrf = aniwaveVRF(id);

    final serversRes = await dio.get(
      "http://$address/ajax/server/list/$id?vrf=$vrf",
      options: Options(headers: {
        ...defaultHeaders,
        "Host": host,
      }),
    );

    final serversJson = await Scrapper.scrapFragment(
      serversRes.data["result"],
      ".servers",
      Flatten([
        Iterate(
          itemScope: "div[data-type='dub'] li",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("DUB")
          }),
        ),
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
      ]),
    );

    if (serversJson == null) {
      return [];
    }

    return AggSourceLoader(
      serversJson.map(
        (json) => AniWaveServerSorceLoader(
          address,
          host,
          Server.fromJson(json),
        ),
      ),
    ).call();
  }
}

class AniWaveServerSorceLoader
    with VidSrcToServerMixin
    implements ContentMediaItemSourceLoader {
  final String address;
  final String host;
  final Server server;

  AniWaveServerSorceLoader(this.address, this.host, this.server);

  @override
  FutureOr<List<ContentMediaItemSource>> call() {
    final prefix = "[${server.prefix}]";
    return extractServer(
      server.title,
      server.id,
      "https://$host",
      descriptionPrefix: prefix,
    );
  }

  @override
  Future<String?> loadSource(String id) async {
    final vrf = aniwaveVRF(id);

    final serverRes = await dio.get(
      "http://$address/ajax/server/$id?vrf=$vrf",
      options: Options(headers: {
        ...defaultHeaders,
        "Host": host,
      }),
    );

    final String? encUrl = serverRes.data["result"]?["url"];

    if (encUrl == null) {
      logger.w("[$host] encUrl not found for source $id");
      return null;
    }

    return aniwaveDecryptURL(encUrl);
  }
}
