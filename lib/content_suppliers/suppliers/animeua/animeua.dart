import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'animeua.g.dart';

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AnimeUAContentDetails extends BaseContentDetails
    with PLayerJSIframe, AsyncMediaItems {
  @override
  final String iframe;

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

  factory AnimeUAContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AnimeUAContentDetailsFromJson(json);
}

class AnimeUASupplier extends ContentSupplier
    with DLEChannelsLoader, DLESearch {
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
  late final contentInfoSelector = Iterate(
    itemScope: ".grid-item",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId(),
      "title": TextSelector.forScope(".poster__desc > .poster__title"),
      "secondaryTitle": TextSelector.forScope(".poster__subtitle"),
      "image": Image.forScope(
        ".poster__img img",
        host,
        attribute: "data-src",
      ),
    }),
  );

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html").toString());

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextSelector.forScope(".page__subcol-main > h1"),
          "originalTitle": TextSelector.forScope(
              ".page__subcol-main > .pmovie__original-title"),
          "image": Image.forScope(
              ".pmovie__poster > img", attribute: "data-src", host),
          "description": TextSelector.forScope(".page__text"),
          "additionalInfo": Flatten([
            Join([
              TextSelector.forScope(
                  ".page__subcol-main .pmovie__subrating--site"),
              TextSelector.forScope(".page__subcol-main > .pmovie__year"),
              TextSelector.forScope(".page__subcol-main > .pmovie__genres"),
            ]),
            Iterate(
              itemScope: ".page__subcol-side2 li",
              item: TextSelector(inline: true),
            )
          ]),
          "similar":
              Scope(scope: ".pmovie__related", item: contentInfoSelector),
          "iframe": Attribute.forScope(
            ".pmovie__player .video-inside iframe",
            "data-src",
          ),
        },
      ),
    ));

    if (result == null) {
      return Future.value(null);
    }

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
  Set<String> get defaultChannels => const {"Новинки", "ТОП 100"};
}
