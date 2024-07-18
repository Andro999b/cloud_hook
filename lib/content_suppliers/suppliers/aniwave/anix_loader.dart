import 'dart:async';

import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/aniwave/aniwave_loader.dart';

class AnixMediaItemLoader extends AniWaveMediaItemLoader {
  AnixMediaItemLoader(super.host, super.mediaId);

  @override
  AniWaveSourceLoader sourceLoader(Episode ep) {
    return AnixSourceLoader(host, ep.id);
  }

  @override
  FutureOr<List<Episode>> srapEpisodeslist(String text) async {
    final episodesJson = await Scrapper.scrapFragment(
      text,
      ".range-wrap",
      Scope(
        scope: ".range",
        item: Iterate(
          itemScope: "div a",
          item: SelectorsToMap({
            "id": Attribute("data-ids"),
            "number": Attribute("data-num"),
          }),
        ),
      ),
    );

    return episodesJson?.map(Episode.fromJson).toList() ?? [];
  }
}

class AnixSourceLoader extends AniWaveSourceLoader {
  AnixSourceLoader(super.host, super.id);

  @override
  Future<List<Server>> scrapServers(String text) async {
    final serversJson = await Scrapper.scrapFragment(
      text,
      ".ani-server-inner",
      Flatten([
        Iterate(
          itemScope: "div[data-type='dub'] .server",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("DUB")
          }),
        ),
        Iterate(
          itemScope: "div[data-type='softsub'] .server",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("S-SUB")
          }),
        ),
        Iterate(
          itemScope: "div[data-type='sub'] .server",
          item: SelectorsToMap({
            "id": Attribute("data-link-id"),
            "title": TextSelector(),
            "prefix": Const("SUB")
          }),
        ),
      ]),
    );

    return serversJson?.map(Server.fromJson).toList() ?? [];
  }
}
