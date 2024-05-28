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
    _mediaItems ??= await Isolate.run(
      () => PlayerJSScrapper(uri: Uri.parse(iframe))
          .scrap(DubSeasonEpisodeConvertStrategy()),
    );

    return _mediaItems!;
  }

  @override
  MediaType get mediaType => MediaType.video;
}

class UAFilmsTVSupplier extends ContentSupplier {
  static const String host = "uafilm.pro";

  @override
  String get name => "UAFilmsTV";

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.series,
        ContentType.anime,
      };

  late final _contentInfoSelector = IterateOverScope(
    itemScope: ".movie-item",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId.forScope("a.movie-title"),
      "title": Text.forScope("a.movie-title"),
      "subtitle": ConcatSelectors([
        Text.forScope(".movie-img>span"),
        Text.forScope(".movie-img>.movie-series"),
      ]),
      "image": Image.forScope(
        ".movie-img img",
        host,
        attribute: "data-src",
      ),
    }),
  );

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(host, "/index.php", {"do": "search"});

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
            if (type.contains(ContentType.anime)) "44",
            if (type.contains(ContentType.cartoon)) ...["2", "46"],
          ],
      },
    );

    final results = await scrapper.scrap(_contentInfoSelector);

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope("h1[itemprop='name']"),
          "originalTitle":
              Text.forScope("span[itemprop='alternativeHeadline']"),
          "image": Image.forScope(".m-img>img", host),
          "description": TextNodes.forScope(".m-desc"),
          "additionalInfo": PrependAll(
              [
                Text.forScope(".m-ratings > .mr-item-rate > b"),
              ],
              IterateOverScope(
                itemScope: ".m-desc>.m-info>.m-info>.mi-item",
                item: ConcatSelectors(
                  [Text.forScope(".mi-label-desc"), Text.forScope(".mi-desc")],
                ),
              )),
          "similar": IterateOverScope(
            itemScope: "#owl-rel a",
            item: SelectorsToMap({
              "id": UrlId(),
              "supplier": Const(name),
              "title": Text.forScope(".rel-movie-title"),
              "image": Image.forScope("img", host, attribute: "data-src"),
            }),
          ),
          "iframe": Attribute.forScope(".player-box>iframe", "src")
        },
      ),
    ));

    return UAFilmsTVContentDetails.fromJson(result);
  }

  final Map<String, String> _channelsPath = {
    "Новинки": "/year/${DateTime.now().year}/page/",
    "Фільми": "/filmys/page/",
    "Серіали": "/serialy/page/",
    "Мультфільми": "/cartoons/page/",
    "Мультсеріали": "/multserialy/page/",
    "Аніме": "/anime/page/"
  };

  @override
  Set<String> get channels => _channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки"};

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {page = 1}) async {
    final path = _channelsPath[channel];

    if (path == null) {
      return const [];
    }

    var tragetPath = path;
    if (path.endsWith("/page/")) {
      tragetPath += page.toString();
    } else if (page > 1) {
      return [];
    }

    final scrapper = Scrapper(uri: Uri.https(host, tragetPath));
    final results = await scrapper.scrap(_contentInfoSelector);

    return results.map((e) => ContentSearchResult.fromJson(e)).toList();
  }
}
