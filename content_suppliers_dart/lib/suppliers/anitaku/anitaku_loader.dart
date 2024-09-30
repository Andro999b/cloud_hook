import 'dart:async';

import '../../extrators/source/doodstream.dart';
import '../../extrators/source/gogostream.dart';
import '../../extrators/source/mp4upload.dart';
import '../../extrators/source/streamwish.dart';
import '../../extrators/utils.dart';
import '../../scrapper/scrapper.dart';
import '../../scrapper/selectors.dart';
import 'anitaku.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';

class AnitakuMediaItemLoader implements ContentMediaItemLoader {
  static const gogocdnHost = "ajax.gogocdn.net";

  final String animeId;

  AnitakuMediaItemLoader(this.animeId);

  @override
  FutureOr<List<ContentMediaItem>> call() async {
    final uri = Uri.https(gogocdnHost, "/ajax/load-list-episode", {
      "ep_start": "0",
      "ep_end": "9999",
      "id": animeId,
    });

    final scrapper = Scrapper(uri: uri);
    final episodes = await scrapper.scrap(
      Iterate(
        itemScope: "li",
        item: SelectorsToMap({
          "name": TextSelector.forScope(".name"),
          "link": Attribute.forScope("a", "href"),
        }),
      ),
    );

    if (episodes == null) {
      return [];
    }

    return episodes.reversed
        .mapIndexed(
          (i, e) => AsyncContentMediaItem(
            number: i,
            title: e["name"] as String,
            sourcesLoader: AnitakuSourceLoader(e["link"] as String),
          ),
        )
        .toList();
  }
}

class AnitakuSourceLoader implements ContentMediaItemSourceLoader {
  final String episodeUrl;

  AnitakuSourceLoader(this.episodeUrl);

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final uri = Uri.https(Anitaku.host, episodeUrl.trim());

    final scrapper = Scrapper(uri: uri);
    final servers = await scrapper.scrap(
      Scope(
        scope: "div.anime_muti_link > ul",
        item: Iterate(
          itemScope: "li",
          item: SelectorsToMap({
            "name": Attribute("class"),
            "video": Attribute.forScope("a", "data-video"),
          }),
        ),
      ),
    );

    if (servers == null) {
      return [];
    }

    return AggSourceLoader(
      servers
          .map(
            (e) => _extractServer(
              e["name"] as String,
              e["video"] as String,
              uri.toString(),
            ),
          )
          .nonNulls
          .toList(),
    ).call();
  }

  ContentMediaItemSourceLoader? _extractServer(
    String name,
    String video,
    String referer,
  ) {
    return switch (name.toLowerCase()) {
      "doodstream" => DoodStreamSourceLoader(
          url: video,
          referer: referer,
        ),
      "vidcdn" => GogoStreamSourceLoader(
          url: video,
          descriptionPrefix: name,
        ),
      "streamwish" || "vidhide" => StreamwishSourceLoader(
          url: video,
          referer: referer,
          descriptionPrefix: name,
        ),
      "mp4upload" => MP4UploadSourceLoader(
          url: video,
          referer: referer,
        ),
      _ => null
    };
  }
}
