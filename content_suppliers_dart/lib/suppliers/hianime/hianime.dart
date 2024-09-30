import 'package:content_suppliers_api/model.dart';
import '../../scrapper/scrapper.dart';
import '../../scrapper/selectors.dart';
import 'hianime_loader.dart';
import '../utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hianime.g.dart';

class HianimeSupplier extends ContentSupplier with PageableChannelsLoader {
  static const siteHost = "hianime.to";
  static final _idRegExp = RegExp(r'\/(?<id>[^\?/]+)');

  @override
  String get name => "Hianime";

  @override
  Set<ContentLanguage> supportedLanguages = const {ContentLanguage.english};

  @override
  Set<ContentType> supportedTypes = const {ContentType.anime};

  @override
  String get host => siteHost;

  late final _contentInfoSelector = SelectorsToMap({
    "id": UrlId.forScope(".film-detail .film-name a", regexp: _idRegExp),
    "supplier": Const(name),
    "image": Attribute.forScope(".film-poster > img", "data-src"),
    "title": TextSelector.forScope(".film-detail .film-name"),
    "secondaryTitle": Concat(
      Iterate(
        itemScope: ".film-detail .fd-infor > *",
        item: TextSelector(),
      ),
      separator: " ",
    )
  });

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.https(siteHost, "/search", {
      "keyword": query,
    });

    final results = await Scrapper(uri: uri).scrap(Scope(
          scope: ".tab-content .film_list-wrap",
          item: Iterate(
            itemScope: ".flw-item",
            item: _contentInfoSelector,
          ),
        )) ??
        [];

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.https(siteHost, "/$id");
    final scrapper = Scrapper(uri: uri);

    const asideSel = "#ani_detail .ani_detail-stage .anis-content";
    final result = await scrapper.scrap(Scope(
      scope: "#wrapper",
      item: SelectorsToMap({
        "supplier": Const(name),
        "id": Const(id),
        "mediaId": Attribute("data-id"),
        "image": Attribute.forScope("$asideSel .anisc-poster img", "src"),
        "title": TextSelector.forScope("$asideSel .anisc-detail .film-name"),
        "description": TextSelector.forScope(
          "$asideSel .anisc-detail .film-description",
        ),
        "additionalInfo": Scope(
            scope: "$asideSel .anisc-info-wrap .anisc-info",
            item: Iterate(
              itemScope: ".item:not(.w-hide)",
              item: TextSelector(inline: true),
            )),
        "similar": Scope(
          scope: "#main-sidebar .block_area-content ul.ulclear",
          item: Iterate(
            itemScope: "li",
            item: _contentInfoSelector,
          ),
        ),
      }),
    ));

    if (result == null) {
      return null;
    }

    return HianimeContentDetails.fromJson(result);
  }

  @override
  Selector get channelInfoSelector => Scope(
        scope: ".tab-content .film_list-wrap",
        item: Iterate(
          itemScope: ".flw-item",
          item: _contentInfoSelector,
        ),
      );

  @override
  Map<String, String> get channelsPath => const {
        "New": "/recently-added?page",
        "Most Popular": "/most-popular?page",
        "Recently Updated": "/recently-updated?page",
        "Top Airing": "/top-airing?page",
        "Movies": "/movie?page",
        "TV Series": "/tv?page",
      };

  @override
  bool isChannelPageable(String path) => path.endsWith("?page");

  @override
  String nextChannelPage(String path, int page) => "$path=$page";
}

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class HianimeContentDetails extends AbstractContentDetails
    with AsyncMediaItems {
  final String mediaId;

  HianimeContentDetails({
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

  factory HianimeContentDetails.fromJson(Map<String, dynamic> json) =>
      _$HianimeContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => HianimeMediaItemLoader(
        id: id,
        mediaId: mediaId,
      );
}
