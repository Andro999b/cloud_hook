import 'package:content_suppliers_api/model.dart';
import 'ufdub_extractor.dart';
import '../utils.dart';
import '../../scrapper/scrapper.dart';
import '../../scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ufdub.g.dart';

class UFDubSupplier extends ContentSupplier
    with PageableChannelsLoader, DLEChannelsLoader, DLESearch {
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
  late final contentInfoSelector = Iterate(
    itemScope: ".cont .short",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId.forScope(".short-text > .short-t"),
      "title": TextSelector.forScope(".short-text > .short-t"),
      "secondaryTitle": TextSelector.forScope(".short-text > .short-c"),
      "image": Image.forScope(".short-i img", host),
    }),
  );

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "div.cols",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextNode.forScope("article .full-title > h1"),
          "originalTitle":
              TextSelector.forScope("article > .full-title > h1 > .short-t-or"),
          "image": Image.forScope(
            "article > .full-desc > .full-text > .full-poster img",
            host,
          ),
          "description": Concat(Iterate(
            itemScope: "article > .full-desc > .full-text p",
            item: TextSelector(),
          )),
          "additionalInfo": Flatten([
            Iterate(
              itemScope: "article > .full-desc > .full-info .fi-col-item",
              item: TextSelector(inline: true),
            ),
            Iterate(
              itemScope:
                  "article > .full-desc > .full-text > .full-poster .voices",
              item: TextSelector(inline: true),
            ),
          ]),
          "similar": Scope(
            scope: "article > .rels",
            item: Iterate(
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

    if (result == null) {
      return Future.value(null);
    }

    return UFDubContentDetails.fromJson(result);
  }

  @override
  late final channelInfoSelector = contentInfoSelector;

  @override
  final Map<String, String> channelsPath = const {
    "Новинки": "/page/",
    "Фільми": "/film/page/",
    "Серіали": "/serial/page/",
    "Аніме": "/anime/page/",
    "Мультфільми": "/cartoons/page/",
    "Мультсеріали": "/cartoon-serial/page/",
    "Дорами": "/cartoon-serial/page/"
  };
}

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class UFDubContentDetails extends AbstractContentDetails with AsyncMediaItems {
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

  final String iframe;

  factory UFDubContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UFDubContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => UFDubMediaExtractor(iframe);
}
