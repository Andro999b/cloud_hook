import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'animeua.g.dart';

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AnimeUAContentDetails extends BaseContentDetails
    with PLayerJSIframe, AsyncIframe {
  AnimeUAContentDetails({
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

  @override
  final String iframe;

  factory AnimeUAContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AnimeUAContentDetailsFromJson(json);
}

class AnimeUASupplier extends ContentSupplier with DLEChannelsLoader {
  @override
  final String host = "animeua.club";

  @override
  String get name => "AnimeUA";

  @override
  Set<ContentType> get supportedTypes => const {ContentType.anime};

  @override
  Set<ContentLanguage> get supportedLanguages =>
      const {ContentLanguage.ukrainian};

  @override
  late final contentInfoSelector = IterateOverScope(
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
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(host, "/index.php", {"do": "search"});
    final scrapper = Scrapper(
      uri: uri.toString(),
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

    final results = await scrapper.scrap(contentInfoSelector);

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html").toString());

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope(".page__subcol-main > h1"),
          "originalTitle":
              Text.forScope(".page__subcol-main > .pmovie__original-title"),
          "image": Image.forScope(
              ".pmovie__poster > img", attribute: "data-src", host),
          "description": Text.forScope(".page__text"),
          "additionalInfo": PrependAll(
            [
              Text.forScope(".page__subcol-main .pmovie__subrating--site"),
              Text.forScope(".page__subcol-main > .pmovie__year"),
              Text.forScope(".page__subcol-main > .pmovie__genres"),
            ],
            IterateOverScope(
              itemScope: ".page__subcol-side2 li",
              item: Text(inline: true),
            ),
          ),
          "similar":
              Scope(scope: ".pmovie__related", item: contentInfoSelector),
          "iframe": Attribute.forScope(
            ".pmovie__player .video-inside iframe",
            "data-src",
          ),
        },
      ),
    ));

    return AnimeUAContentDetails.fromJson(result);
  }

  @override
  final Map<String, String> channelsPath = const {
    "Новинки": "/page/",
    "ТОП 100": "/top.html",
    "Повнометражки": "/film/page/",
    "Аніме серіали": "/anime/page/"
  };

  @override
  Set<String> get channels => channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки", "ТОП 100"};
}
