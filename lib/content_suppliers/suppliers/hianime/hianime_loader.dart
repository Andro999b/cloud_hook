import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/source/megacloud.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/hianime/hianime.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

class HianimeMediaItemLoader implements ContentMediaItemLoader {
  final String id;
  final String mediaId;

  const HianimeMediaItemLoader({
    required this.id,
    required this.mediaId,
  });

  @override
  FutureOr<List<ContentMediaItem>> call() async {
    final episodesRes = await dio.getUri(
      Uri.http(HianimeSupplier.siteHost, "/ajax/v2/episode/list/$mediaId"),
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": "https://${HianimeSupplier.siteHost}/watch/$id",
      }),
    );

    final data = episodesRes.data is Map
        ? episodesRes.data
        : json.decode(episodesRes.data);
    final episodes = await Scrapper.scrapFragment(
            data["html"],
            ".seasons-block",
            Iterate(
              itemScope: ".ep-item",
              item: SelectorsToMap({
                "id": Attribute("data-id"),
                "title": Attribute("title"),
              }),
            )) ??
        [];

    return episodes
        .mapIndexed(
          (idx, epJson) => AsyncContentMediaItem(
            number: idx,
            title: epJson["title"] as String,
            sourcesLoader: HianimeSourceLoader(
              id: epJson["id"] as String,
            ),
          ),
        )
        .toList();
  }
}

class HianimeSourceLoader implements ContentMediaItemSourceLoader {
  final String id;

  const HianimeSourceLoader({
    required this.id,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final serversRes = await dio.getUri(
      Uri.http(
        HianimeSupplier.siteHost,
        "/ajax/v2/episode/servers",
        {
          "episodeId": id,
        },
      ),
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": "https://${HianimeSupplier.siteHost}/watch/$id",
      }),
    );

    final data =
        serversRes.data is Map ? serversRes.data : json.decode(serversRes.data);
    final servers = await Scrapper.scrapFragment(
            "<wrapper>${data["html"]}</wrapper>",
            "wrapper",
            Flatten([
              Iterate(
                itemScope: ".servers-sub .item",
                item: SelectorsToMap({
                  "id": Attribute("data-id"),
                  "title": TextSelector(),
                  "prefix": Const("SUB")
                }),
              ),
              Iterate(
                itemScope: ".servers-dub .item",
                item: SelectorsToMap({
                  "id": Attribute("data-id"),
                  "title": TextSelector(),
                  "prefix": Const("DUB")
                }),
              ),
            ])) ??
        [];

    return AggSourceLoader(
      servers
          .mapIndexed((idx, s) => HianimeServerSorceLoader(
                id: s["id"] as String,
                title: s["title"] as String,
                prefix: s["prefix"] as String,
              ))
          .toList(),
    ).call();
  }
}

class HianimeServerSorceLoader implements ContentMediaItemSourceLoader {
  final String id;
  final String title;
  final String prefix;

  const HianimeServerSorceLoader({
    required this.id,
    required this.title,
    required this.prefix,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() {
    return switch (title) {
      "HD-1" || "HD-2" => _loadMegaCloud(id),
      _ => [],
    };
  }

  FutureOr<List<ContentMediaItemSource>> _loadMegaCloud(String id) async {
    final url = await _loadSource(id);
    if (url == null) {
      logger.w("[$id] url not found");
      return [];
    }

    return MegacloudSourceLoader(
      url: url,
      descriptionPrefix: "[$prefix] $title",
    ).call();
  }

  Future<String?> _loadSource(String id) async {
    final serverRes = await dio.getUri(
      Uri.http(HianimeSupplier.siteHost, "/ajax/v2/episode/sources", {
        "id": id,
      }),
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": HianimeSupplier.siteHost,
      }),
    );

    final data =
        serverRes.data is Map ? serverRes.data : json.decode(serverRes.data);

    return data["link"];
  }
}
