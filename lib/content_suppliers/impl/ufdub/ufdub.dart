import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/impl/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

part 'ufdub.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class UFDubContentDetails extends BaseContentDetails {
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

  Map<String, dynamic> toJson() => _$UFDubContentDetailsToJson(this);

  @override
  MediaType get mediaType => MediaType.video;

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    try {
      _mediaItems ??= await Isolate.run(() => _extractMediaItems(iframe));
    } catch (e, staclTrace) {
      logger.e("UFDub mediaitems error: $e", stackTrace: staclTrace);
    }

    return _mediaItems!;
  }

  static final _episodeUrlRegExp =
      // ignore: unnecessary_string_escapes
      RegExp("https:\/\/ufdub.com\/video\/VIDEOS\.php\?(.*?)'");

  Future<List<ContentMediaItem>> _extractMediaItems(String iframe) async {
    final iframeRes =
        await http.get(Uri.parse(iframe), headers: defaultHeaders);
    final iframeContent = iframeRes.body;

    final matches = _episodeUrlRegExp.allMatches(iframeContent);

    final episodesUrls =
        matches.map((e) => e.group(0)!).where((e) => !e.contains("Трейлер"));

    return episodesUrls.mapIndexed((index, e) {
      final uri = Uri.parse(e);
      return SimpleContentMediaItem(
        number: index,
        title: uri.queryParameters["Seriya"] ?? "",
        sources: [
          SimpleContentMediaItemSource(description: "UFDub", link: uri)
        ],
      );
    }).toList();
  }
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
