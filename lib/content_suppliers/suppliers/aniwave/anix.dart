import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/aniwave/anix_loader.dart';
import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anix.g.dart';

const _siteHost = "anix.to";

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AnixContentDetails extends BaseContentDetails with AsyncMediaItems {
  final String mediaId;

  AnixContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaId,
  });

  factory AnixContentDetails.fromJson(Map<String, dynamic> json) => _$AnixContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => AnixMediaItemLoader(
        _siteHost,
        mediaId,
      );
}

class AnixSupplier extends ContentSupplier with PageableChannelsLoader {
  static final _idRegExp = RegExp(r'\/anime\/(?<id>[^\/]+)');

  @override
  final host = _siteHost;

  @override
  String get name => "Anix";

  @override
  Set<ContentLanguage> get supportedLanguages => {ContentLanguage.english};

  @override
  Set<ContentType> get supportedTypes => {ContentType.anime};

  @override
  late final contentInfoSelector = Iterate(
    itemScope: "div.ani .piece > .inner",
    item: SelectorsToMap({
      "supplier": Const(name),
      "id": UrlId.forScope("> a", regexp: _idRegExp),
      "title": TextSelector.forScope(".ani-detail .ani-name"),
      "secondaryTitle": TextSelector.forScope(".abs-info"),
      "image": Attribute.forScope(".poster img", "src"),
    }),
  );

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "filter", {"keyword": query});

    final scrapper = Scrapper(uri: uri.toString(), headers: {"Host": host});
    final results = await scrapper.scrap(contentInfoSelector) ?? [];

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.https(host, "/anime/$id");
    final scrapper = Scrapper(uri: uri.toString(), headers: {"Host": host});

    final results = await scrapper.scrap(
      Scope(
        scope: "main",
        item: SelectorsToMap({
          "supplier": Const(name),
          "id": Const(id),
          "mediaId": Attribute.forScope(">.watch-wrap", "data-id"),
          "image": Attribute.forScope("#ani-detail-info .ani-data .poster-wrap img", "src"),
          "title": TextSelector.forScope("#ani-detail-info .ani-data .maindata h1.ani-name"),
          "description": TextSelector.forScope("#ani-detail-info .ani-data .maindata .description .full"),
          "additionalInfo": Iterate(
            itemScope: "#ani-detail-info .metadata .limiter > div",
            item: Concat.selectors(
              [TextSelector.forScope("div"), TextSelector.forScope("span")],
              separator: " ",
            ),
          ),
          "similar": Scope(
            scope: ".main-inner.swap .sidebar .border-top .section-body",
            item: Iterate(
              itemScope: ".piece",
              item: SelectorsToMap({
                "supplier": Const(name),
                "id": UrlId(regexp: _idRegExp),
                "title": TextSelector.forScope(".ani-detail .ani-name"),
                "image": Transform(
                  item: Attribute.forScope(".poster img", "src"),
                  map: (url) => url.replaceAll("@100", ""),
                ),
              }),
            ),
          ),
        }),
      ),
    );

    if (results == null) {
      return null;
    }

    return AnixContentDetails.fromJson(results);
  }

  @override
  Map<String, String> get channelsPath => const {
        "All": "/home",
        "Ongoing": "/ongoing?page",
        "Movie": "/movie?page",
        "TV Series": "/tv?page",
        "OVA": "/ova?page",
        "ONA": "/ona?page",
      };

  @override
  bool isChannelPageable(String path) => path.endsWith("?page");

  @override
  String nextChannelPage(String path, int page) => "$path=$page";
}
