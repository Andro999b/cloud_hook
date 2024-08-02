import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'eneyida.g.dart';

class EneyidaSupplier extends ContentSupplier
    with PageableChannelsLoader, DLEChannelsLoader, DLESearch {
  @override
  final String host = "eneyida.tv";

  @override
  String get name => "Eneyida";

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

  late final _contentInfoFieldSelector = SelectorsToMap({
    "supplier": Const(name),
    "id": UrlId.forScope("a.short_title"),
    "title": TextSelector.forScope("a.short_title"),
    "secondaryTitle": TextSelector.forScope(".short_subtitle"),
    "image": Image.forScope(
      "a.short_img img",
      host,
      attribute: "data-src",
    ),
  });

  @override
  late final contentInfoSelector = Iterate(
    itemScope: "article.short",
    item: _contentInfoFieldSelector,
  );

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "#main",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextSelector.forScope("#full_header-title > h1"),
          "originalTitle": TextSelector.forScope(
              "#full_header-title > .full_header-subtitle"),
          "image": Image.forScope(".full_content-poster > img", host),
          "description": TextSelector.forScope("#full_content-desc > p"),
          "additionalInfo": Flatten([
            Join([
              TextSelector.forScope(".full_rating > .db_rates > .r_imdb > span")
            ]),
            Filter(
              Iterate(
                itemScope: "#full_info li",
                item: TextSelector(inline: true),
              ),
              filter: (element) => !element.startsWith("Вік"),
            ),
          ]),
          "similar": Iterate(
            itemScope: ".short.related_item",
            item: _contentInfoFieldSelector,
          ),
          "iframe": Attribute.forScope(".tabs_b.visible iframe", "src"),
        },
      ),
    ));

    if (result == null) {
      return Future.value(null);
    }

    return EneyidaContentDetails.fromJson(result);
  }

  @override
  late final channelInfoSelector = contentInfoSelector;

  @override
  final Map<String, String> channelsPath = const {
    "Фільми": "/films/page/",
    "Серіали": "/series/page/",
    "Аніме": "/anime/page/",
    "Мультфільми": "/cartoon/page/",
    "Мультсеріали": "/cartoon-series/page/",
  };
}

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class EneyidaContentDetails extends AbstractContentDetails
    with PLayerJSIframe, AsyncMediaItems {
  EneyidaContentDetails({
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

  factory EneyidaContentDetails.fromJson(Map<String, dynamic> json) =>
      _$EneyidaContentDetailsFromJson(json);
}
