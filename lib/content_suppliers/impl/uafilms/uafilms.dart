import 'package:cloud_hook/content_suppliers/impl/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uafilms.g.dart';

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class UAFilmsContentDetails extends BaseContentDetails
    with PLayerJSIframe, AsyncIframe {
  UAFilmsContentDetails({
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

  factory UAFilmsContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UAFilmsContentDetailsFromJson(json);
}

class UAFilmsSupplier extends ContentSupplier with DLEChannelsLoader {
  @override
  final String host = "uafilm.pro";

  @override
  String get name => "UAFilms";

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.series,
        ContentType.anime,
      };

  @override
  Set<ContentLanguage> get supportedLanguages =>
      const {ContentLanguage.ukrainian};

  @override
  late final contentInfoSelector = IterateOverScope(
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
      uri: uri.toString(),
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

    return UAFilmsContentDetails.fromJson(result);
  }

  @override
  final Map<String, String> channelsPath = {
    "Новинки": "/year/${DateTime.now().year}/page/",
    "Фільми": "/filmys/page/",
    "Серіали": "/serialy/page/",
    "Мультфільми": "/cartoons/page/",
    "Мультсеріали": "/multserialy/page/",
    "Аніме": "/anime/page/"
  };

  @override
  Set<String> get channels => channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки"};
}
