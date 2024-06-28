import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/aniwave/aniwave_extractor.dart';
import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aniwave.g.dart';

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AniWaveContentDetails extends BaseContentDetails with AsyncMediaItems {
  final String mediaId;

  AniWaveContentDetails({
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

  factory AniWaveContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AniWaveContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => AniWaveExtractor(
        AniWaveSupplier.address,
        AniWaveSupplier.host,
        mediaId,
      );
}

class AniWaveSupplier extends ContentSupplier {
  static const String address = cloudWallIp;
  static const String host = "aniwave.to";
  static final _idRegExp = RegExp(r'\/watch\/(?<id>[^\/]+)');

  @override
  String get name => "AniWave";

  @override
  Set<ContentLanguage> get supportedLanguages => {ContentLanguage.english};

  @override
  Set<ContentType> get supportedTypes => {ContentType.anime};

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.http(address, "filter", {"keyword": query});

    final scrapper = Scrapper(uri: uri.toString(), headers: {"Host": host});
    final results = await scrapper.scrap(
          Scope(
            scope: "#list-items",
            item: Iterate(
              itemScope: ".item > .inner",
              item: SelectorsToMap({
                "supplier": Const(name),
                "id": UrlId.forScope(".poster > a", regexp: _idRegExp),
                "title": TextSelector.forScope(".info .name"),
                "secondaryTitle": TextSelector.forScope(".info .genre"),
                "image": Attribute.forScope(".poster img", "src"),
              }),
            ),
          ),
        ) ??
        [];

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.http(address, "/watch/$id");

    final scrapper = Scrapper(uri: uri.toString(), headers: {"Host": host});
    final results = await scrapper.scrap(
      Scope(
        scope: "#body",
        item: SelectorsToMap({
          "supplier": Const(name),
          "id": Const(id),
          "mediaId": Attribute.forScope("#watch-main", "data-id"),
          "image": Attribute.forScope(".binfo .poster img", "src"),
          "title": TextSelector.forScope(".binfo h1.title"),
          "description":
              TextSelector.forScope(".binfo .info .synopsis .content"),
          "additionalInfo": Iterate(
            itemScope: ".bmeta .meta > div",
            item: Concat.selectors(
              [TextNode(), TextSelector.forScope("span")],
              separator: " ",
            ),
          ),
          "similar": Scope(
            scope: "#watch-second aside.sidebar .body",
            item: Iterate(
              itemScope: ".item",
              item: SelectorsToMap({
                "supplier": Const(name),
                "id": UrlId(regexp: _idRegExp),
                "title": TextSelector.forScope(".info .name"),
                "secondaryTitle": TextSelector.forScope(".info .meta"),
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

    return AniWaveContentDetails.fromJson(results);
  }

  final Map<String, String> _channelsPath = const {
    "Trending": "/ajax/home/widget/trending",
    "All": "/ajax/home/widget/updated-all",
    "Recently Updated (SUB)": "/ajax/home/widget/updated-sub",
    "Recently Updated (DUB)": "/ajax/home/widget/updated-dub",
    "Random": "/ajax/home/widget/random",
  };

  @override
  Set<String> get channels => _channelsPath.keys.toSet();

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async {
    final path = _channelsPath[channel];

    if (path == null) {
      return [];
    }

    final uri = Uri.http(cloudWallIp, path, {
      "page": page.toString(),
    });

    final res = await dio.getUri(
      uri,
      options: Options(headers: {
        ...defaultHeaders,
        "Host": host,
      }),
    );

    final results = await Scrapper.scrapFragment(
      res.data["result"],
      ".items",
      Iterate(
        itemScope: ".item",
        item: SelectorsToMap({
          "supplier": Const(name),
          "id": UrlId.forScope(".poster > a", regexp: _idRegExp),
          "title": TextSelector.forScope(".info .name"),
          "image": Attribute.forScope(".poster img", "src"),
        }),
      ),
    );

    if (results == null) {
      return [];
    }

    return results.map(ContentSearchResult.fromJson).toList();
  }
}
