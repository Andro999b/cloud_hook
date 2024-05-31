import 'package:cloud_hook/content_suppliers/media_extrators/extractor.dart';
import 'package:cloud_hook/content_suppliers/impl/ufdub/ufdub_extractor.dart';
import 'package:cloud_hook/content_suppliers/impl/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ufdub.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class UFDubContentDetails extends BaseContentDetails with AsyncIframe {
  UFDubContentDetails({
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

  factory UFDubContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UFDubContentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UFDubContentDetailsToJson(this);

  @override
  MediaExtractor get mediaExtractor => UFDubMediaExtractor();
}

class UFDubSupplier extends ContentSupplier with DLEChannelsLoader {
  @override
  final String host = "ufdub.com";

  @override
  String get name => "UFDub";

  @override
  Set<ContentType> get supportedTypes => const {ContentType.anime};

  @override
  Set<ContentLanguage> get supportedLanguages =>
      const {ContentLanguage.ukrainian};

  @override
  late final contentInfoSelector = IterateOverScope(
    itemScope: ".cont .short",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId.forScope(".short-text > .short-t"),
      "title": Text.forScope(".short-text > .short-t"),
      "subtitle": Text.forScope(".short-text > .short-c"),
      "image": Image.forScope(".short-i img", host),
    }),
  );

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(host, "/index.php");
    final scrapper = Scrapper(
      uri: uri,
      method: "post",
      headers: const {"Content-Type": "application/x-www-form-urlencoded"},
      form: {"do": "search", "subaction": "search", "story": query},
    );

    final results = await scrapper.scrap(contentInfoSelector);

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "div.cols",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextNodes.forScope("article .full-title > h1"),
          "originalTitle":
              Text.forScope("article > .full-title > h1 > .short-t-or"),
          "image": Image.forScope(
            "article > .full-desc > .full-text > .full-poster img",
            host,
          ),
          "description": Concat(IterateOverScope(
            itemScope: "article > .full-desc > .full-text p",
            item: Text(),
          )),
          "additionalInfo": Expand([
            IterateOverScope(
              itemScope: "article > .full-desc > .full-info .fi-col-item",
              item: Text(inline: true),
            ),
            IterateOverScope(
              itemScope:
                  "article > .full-desc > .full-text > .full-poster .voices",
              item: Text(inline: true),
            ),
          ]),
          "similar": Scope(
            scope: "article > .rels",
            item: IterateOverScope(
              itemScope: ".rel",
              item: SelectorsToMap({
                "id": UrlId(),
                "supplier": Const(name),
                "title": Attribute.forScope("img", "alt"),
                "image": Image.forScope("img", host)
              }),
            ),
          ),
          "iframe": Attribute.forScope("article input", "value"),
        },
      ),
    ));

    return UFDubContentDetails.fromJson(result);
  }

  @override
  final Map<String, String> channelsPath = const {
    "Новинки": "/page/",
    "Аніме": "/anime/page/",
    "Серіали": "/serial/page/",
    "Фільми": "/film/page/",
    "Мультфільми": "/cartoons/page/",
    "Мультсеріали": "/cartoon-serial/page/",
    "Дорами": "/cartoon-serial/page/"
  };

  @override
  Set<String> get channels => channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки"};
}
