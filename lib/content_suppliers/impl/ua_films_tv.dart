import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ua_films_tv.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class UAFilmsTVContentDetails extends BaseContentDetails {
  UAFilmsTVContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.iframe,
  });

  final String iframe;

  factory UAFilmsTVContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UAFilmsTVContentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UAFilmsTVContentDetailsToJson(this);

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    _mediaItems ??= await Isolate.run(() => PlayerJSScrapper(
          uri: Uri.parse(iframe),
          convertStrategy: DubSeasonEpisodeConvertStrategy(),
        ).scrap());

    return _mediaItems!;
  }

  @override
  MediaType get mediaType => MediaType.video;
}

class UAFilmsTVSupplier extends ContentSupplier {
  static const String baseUrl = "uafilm.pro";

  @override
  String get name => "UAFilmsTV";

  @override
  Set<String> channels = const {
    "Новинки",
    "Фільми",
    "Серіали",
    "Мультфільми",
    "Мультсеріали",
    "Аніме"
  };

  @override
  Set<String> get defaultChannels => const {
        "Новинки",
      };

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.series,
        ContentType.anime,
      };

  late final _movieItemSelector = IterateOverScope(
    itemScope: ".movie-item",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId.forScope("a.movie-title"),
      "title": Text.forScope("a.movie-title"),
      "subtitle": Concat([
        Text.forScope(".movie-img>span"),
        Text.forScope(".movie-img>.movie-series"),
      ]),
      "image": Image.forScope(
        ".movie-img img",
        baseUrl,
        attribute: "data-src",
      ),
    }),
  );

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(baseUrl, "/index.php", {"do": "search"});

    final scrapper = Scrapper(
      uri: uri,
      method: "post",
      headers: const {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      form: {
        "do": "search",
        "subaction": "search",
        "full_search": "1",
        "story": query,
        "sortby": "date",
        "resorder": "desc",
        if (type.isNotEmpty)
          "catlist": [
            if (type.contains(ContentType.movie)) "1",
            if (type.contains(ContentType.series)) "3",
            if (type.contains(ContentType.anime)) "46",
            if (type.contains(ContentType.cartoon)) ...["2", "46"],
          ],
      },
    );

    final results = await scrapper.scrap(_movieItemSelector);

    return results.map((e) => ContentSearchResult.fromJson(e)).toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(baseUrl, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope("h1[itemprop='name']"),
          "originalTitle":
              Text.forScope("span[itemprop='alternativeHeadline']"),
          "image": Image.forScope(".m-img>img", baseUrl),
          "description": TextNodes.forScope(".m-desc"),
          "additionalInfo": IterateOverScope(
            itemScope: ".m-desc>.m-info>.m-info>.mi-item",
            item: Concat(
              [Text.forScope(".mi-label-desc"), Text.forScope(".mi-desc")],
            ),
          ),
          "similar": IterateOverScope(
            itemScope: "#owl-rel a",
            item: SelectorsToMap({
              "id": UrlId(),
              "supplier": Const(name),
              "title": Text.forScope(".rel-movie-title"),
              "image": Image.forScope("img", baseUrl, attribute: "data-src"),
            }),
          ),
          "iframe": Attribute.forScope(".player-box>iframe", "src")
        },
      ),
    ));

    return UAFilmsTVContentDetails.fromJson(result);
  }

  @override
  Future<SupplierChannels> loadChannels(
    Set<String> channels,
  ) async {
    return {
      for (final channel in channels) channel: await _loadChannel(channel)
    };
  }

  Future<List<ContentInfo>> _loadChannel(String channel) async {
    final path = switch (channel) {
      "Новинки" => "/year/${DateTime.now().year}/",
      "Фільми" => "/filmys/",
      "Серіали" => "/serialy/",
      "Мультфільми" => "/cartoons/",
      "Мультсеріали" => "/multserialy/",
      "Аніме" => "/anime/",
      _ => null
    };

    if (path == null) {
      return const [];
    }

    final scrapper = Scrapper(uri: Uri.https(baseUrl, path));
    final results = await scrapper.scrap(_movieItemSelector);

    return results.map((e) => ContentSearchResult.fromJson(e)).toList();
  }
}
