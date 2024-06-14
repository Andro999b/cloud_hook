import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'eneyida.g.dart';

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class EneyidaContentDetails extends BaseContentDetails
    with PLayerJSIframe, AsyncIframe {
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

class EneyidaSupplier extends ContentSupplier with DLEChannelsLoader {
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
    "title": Text.forScope("a.short_title"),
    "secondaryTitle": Text.forScope(".short_subtitle"),
    "image": Image.forScope(
      "a.short_img img",
      host,
      attribute: "data-src",
    ),
  });

  @override
  late final contentInfoSelector = IterateOverScope(
    itemScope: "article.short",
    item: _contentInfoFieldSelector,
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
      scope: "#main",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope("#full_header-title > h1"),
          "originalTitle":
              Text.forScope("#full_header-title > .full_header-subtitle"),
          "image": Image.forScope(".full_content-poster > img", host),
          "description": Text.forScope("#full_content-desc > p"),
          "additionalInfo": PrependAll(
            [Text.forScope(".full_rating > .db_rates > .r_imdb > span")],
            Filter(
              IterateOverScope(
                itemScope: "#full_info li",
                item: Text(inline: true),
              ),
              filter: (element) => !element.startsWith("Вік"),
            ),
          ),
          "similar": IterateOverScope(
            itemScope: ".short.related_item",
            item: _contentInfoFieldSelector,
          ),
          "iframe": Attribute.forScope(".tabs_b.visible iframe", "src"),
        },
      ),
    ));

    return EneyidaContentDetails.fromJson(result);
  }

  @override
  final Map<String, String> channelsPath = const {
    "Фільми": "/films/page/",
    "Серіали": "/series/page/",
    "Мультфільми": "/cartoon/page/",
    "Мультсеріали": "/cartoon-series/page/",
    "Аніме": "/anime/page/",
  };

  @override
  Set<String> get channels => channelsPath.keys.toSet();
}
