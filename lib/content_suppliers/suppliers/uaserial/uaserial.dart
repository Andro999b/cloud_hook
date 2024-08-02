import 'dart:async';

import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uaserial.g.dart';

const _siteHost = "uaserial.tv";

class UASerialSupplier extends ContentSupplier with PageableChannelsLoader {
  @override
  final host = _siteHost;

  @override
  String get name => "UASerial";

  @override
  Set<ContentLanguage> get supportedLanguages => const {
        ContentLanguage.ukrainian,
      };

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.series,
        ContentType.anime,
      };

  late final _contentInfoSelector = Iterate(
    itemScope: ".row .col",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": Transform(
        item: Attribute.forScope(".item > a", "href"),
        map: (str) => str.substring(1),
      ),
      "title": TextSelector.forScope(".item__data > a > div"),
      "secondaryTitle": Concat(
        Iterate(
          itemScope: ".item__data .info__item",
          item: TextNode(),
        ),
        separator: " ",
      ),
      "image": Image.forScope(
        ".item > a > .img-wrap > img",
        host,
      )
    }),
  );

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "/search", {"query": query});
    final results = await Scrapper(uri: uri).scrap(
          Scope(
            scope: "#block-search-page .block__search__actors",
            item: _contentInfoSelector,
          ),
        ) ??
        [];

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.https(host, "/$id");
    final scrapper = Scrapper(uri: uri);
    final result = await scrapper.scrap(
      Scope(
        scope: "#container",
        item: SelectorsToMap({
          "id": Const(id),
          "supplier": Const(name),
          "title": TextSelector.forScope(".block__breadcrumbs .current"),
          "originalTitle": TextSelector.forScope(".header--title .original"),
          "image": Image.forScope(".poster img", host),
          "description": TextSelector.forScope(
            ".player__info .player__description .text",
          ),
          "additionalInfo": Filter(
            Flatten([
              Iterate(
                itemScope: ".movie-data .movie-data-item",
                item: Concat.selectors(
                  [
                    TextSelector.forScope(".type", inline: true),
                    TextSelector.forScope(".value", inline: true),
                  ],
                  separator: " ",
                ),
              ),
              Iterate(
                itemScope: ".movie__genres__container .selection__badge",
                item: TextSelector(inline: true),
              ),
            ]),
            filter: (s) => s.isNotEmpty,
          ),
          "episodes": Iterate(
            itemScope: "#select-series option",
            item: SelectorsToMap({
              "name": TextSelector(),
              "iframe": Attribute("value"),
            }),
          ),
          "iframe": Attribute.forScope("#embed", "src")
        }),
      ),
    );

    return result != null ? UASerialContentDetails.fromJson(result) : null;
  }

  @override
  late final channelInfoSelector = Scope(
    scope: "#filters-grid-content .row",
    item: _contentInfoSelector,
  );

  @override
  Map<String, String> channelsPath = {
    "Фільми": "/movie",
    "Серіали": "/serial",
    "Аніме": "/anime",
    "Мультфільми": "/cartoon-movie",
    "Мультсеріали": "/cartoon-series",
  };

  @override
  bool isChannelPageable(String path) => true;

  @override
  String nextChannelPage(String path, int page) => "$path/$page";
}

@JsonSerializable(createToJson: false)
class UASerialContentDetails extends AbstractContentDetails {
  final Iterable<ContentMediaItem> _mediaItems;
  final String iframe;
  final List<UASerialEpisode> episodes;

  UASerialContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.iframe,
    required this.episodes,
  }) : _mediaItems = _generateMediaLitems(iframe, episodes);

  @override
  Iterable<ContentMediaItem> get mediaItems => _mediaItems;

  factory UASerialContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UASerialContentDetailsFromJson(json);

  static Iterable<ContentMediaItem> _generateMediaLitems(
    String iframe,
    List<UASerialEpisode> episodes,
  ) {
    if (episodes.isNotEmpty) {
      return episodes
          .mapIndexed(
            (number, episode) => AsyncContentMediaItem(
              number: number,
              title: episode.name,
              sourcesLoader: UASerialSourceLoader(episode.iframe),
            ),
          )
          .toList();
    }

    return [
      AsyncContentMediaItem(
        number: 0,
        title: "",
        sourcesLoader: UASerialSourceLoader(iframe),
      )
    ];
  }
}

class UASerialSourceLoader implements ContentMediaItemSourceLoader {
  final String iframe;

  UASerialSourceLoader(this.iframe);

  @override
  Future<List<ContentMediaItemSource>> call() async {
    final uri = Uri.https(_siteHost, iframe);
    final links = await Scrapper(uri: uri).scrap(
      Iterate(
        itemScope: "option[data-type='link']",
        item: SelectorsToMap({
          "description": TextSelector(),
          "link": Attribute("value"),
        }),
      ),
    );

    if (links == null) {
      logger.w("[uaserial] no links found");
      return [];
    }

    final sourceLoaders = links
        .map(
          (e) => switch (Uri.parse(e['link'] as String).authority) {
            "ashdi.vip" || "tortuga.wtf" => PlayerJSSourceLoader(
                e['link'] as String,
                SimpleUrlConvertStrategy(prefix: e['description'] as String),
              ),
            _ => null,
          },
        )
        .nonNulls
        .toList();

    return AggSourceLoader(sourceLoaders).call();
  }
}

@JsonSerializable(createToJson: false)
class UASerialEpisode {
  final String name;
  final String iframe;

  const UASerialEpisode({
    required this.name,
    required this.iframe,
  });

  factory UASerialEpisode.fromJson(Map<String, dynamic> json) =>
      _$UASerialEpisodeFromJson(json);
}
