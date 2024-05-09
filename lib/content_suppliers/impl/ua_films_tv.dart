import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ua_films_tv.g.dart';

@JsonSerializable()
class UAFilmsTVContentDetails extends BaseContentDetails {
  UAFilmsTVContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.oroginalTitle,
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
}

class UAFilmsTVSupplier implements ContentSupplier {
  static const String baseUrl = "uafilm.pro";

  @override
  String get name => "UAFilmsTV";

  @override
  Set<ContentType> get supportedTypes => {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.tvShow,
        ContentType.anime,
      };

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(
      baseUrl,
      "/index.php",
      {
        "do": "search",
      },
    );

    final scrapper = Scrapper(
      uri: uri,
      method: "post",
      headers: const {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "do": "search",
        "subaction": "search",
        "full_search": "1",
        "story": query,
        "sortby": "date",
        "resorder": "desc"
      },
    );

    final results = await scrapper.scrap(ItemsList(
      itemScope: ".movie-item",
      child: SelectorsMap({
        "supplier": Const(name),
        "id": UrlId.forScope("a.movie-title"),
        "title": Text.forScope("a.movie-title"),
        "subtitle": Join([
          Text.forScope(".movie-img>span"),
          Text.forScope(".movie-img>.movie-series"),
        ]),
        "image": Image.forScope(
          ".movie-img img",
          baseUrl,
          attribute: "data-src",
        ),
      }),
    ));

    return results.map((e) => ContentSearchResult.fromJson(e)).toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final uri = Uri.https(
      baseUrl,
      "/$id.html",
    );

    final scrapper = Scrapper(uri: uri);

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      child: SelectorsMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope("h1[itemprop='name']"),
          "oroginalTitle":
              Text.forScope("span[itemprop='alternativeHeadline']"),
          "image": Image.forScope(".m-img>img", baseUrl),
          "description": TextNodes.forScope(".m-desc"),
          "additionalInfo": ItemsList(
            itemScope: ".m-desc>.m-info>.m-info>.mi-item",
            child: SelectorsMap({
              "name": Text.forScope(".mi-label-desc"),
              "value": Text.forScope(".mi-desc")
            }),
          ),
          "similar": ItemsList(
            itemScope: "#owl-rel a",
            child: SelectorsMap({
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
}
