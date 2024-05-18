import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'animeua_club.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class AnimeUAClubContentDetails extends BaseContentDetails {
  AnimeUAClubContentDetails({
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

  factory AnimeUAClubContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AnimeUAClubContentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeUAClubContentDetailsToJson(this);

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    _mediaItems ??= await Isolate.run(
      () => PlayerJSScrapper(
        uri: Uri.parse(iframe),
      ).scrap(DubSeasonEpisodeConvertStrategy()),
    );

    return _mediaItems!;
  }
}

class AnimeUAClubSupplier extends ContentSupplier {
  static const String host = "animeua.club";

  @override
  String get name => "AnimeUAClub";

  @override
  Set<ContentType> get supportedTypes => const {ContentType.anime};

  late final _contentInfoSelector = IterateOverScope(
    itemScope: ".grid-item",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId(),
      "title": Text.forScope(".poster__desc > .poster__title"),
      "subtitle": Text.forScope(".poster__subtitle"),
      "image": Image.forScope(
        ".poster__img img",
        host,
        attribute: "data-src",
      ),
    }),
  );

  @override
  Future<List<ContentSearchResult>> search(
      String query, Set<ContentType> type) async {
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
        "full_search": "0",
        "search_start": "0",
        "result_from": "1",
        "story": query,
        "sortby": "date",
        "resorder": "desc",
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
          "id": Const(Uri.encodeComponent(id)),
          "supplier": Const(name),
          "title": Text.forScope(".page__subcol-main > h1"),
          "originalTitle":
              Text.forScope(".page__subcol-main > .pmovie__original-title"),
          "image": Image.forScope(
              ".pmovie__poster > img", attribute: "data-src", host),
          "description": Text.forScope(".page__text"),
          "additionalInfo": Expand([
            Join([
              Text.forScope(".page__subcol-main > .pmovie__year"),
              Text.forScope(".page__subcol-main > .pmovie__genres"),
            ]),
            IterateOverScope(
              itemScope: ".page__subcol-side2 li",
              item: Text(inline: true),
            )
          ]),
          "similar":
              Scope(scope: ".pmovie__related", item: _contentInfoSelector),
          "iframe": Attribute.forScope(
            ".pmovie__player .video-inside iframe",
            "data-src",
          ),
        },
      ),
    ));

    return AnimeUAClubContentDetails.fromJson(result);
  }

  final Map<String, String> _channelsPath = const {
    "Новинки": "/page/",
    "ТОП 100": "/top.html",
    "Повнометражки": "/film/page/",
    "Аніме серіали": "/anime/page/"
  };

  @override
  Set<String> get channels => _channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки", "ТОП 100"};

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
