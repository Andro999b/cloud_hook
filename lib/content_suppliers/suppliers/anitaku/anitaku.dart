import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/suppliers/anitaku/anitaku_loader.dart';
import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anitaku.g.dart';

class Anitaku extends ContentSupplier {
  static const host = "anitaku.pe";

  @override
  String get name => "Anitaku";

  @override
  Set<ContentLanguage> get supportedLanguages =>
      const {ContentLanguage.english};

  @override
  Set<ContentType> get supportedTypes => const {ContentType.anime};

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "/search.html", {"keyword": query});

    final scrapper = Scrapper(uri: uri);
    final results = await scrapper.scrap(
      Scope(
        scope: ".last_episodes .items",
        item: Iterate(
          itemScope: "li",
          item: SelectorsToMap({
            "supplier": Const(name),
            "id": Transform(
              item: Attribute.forScope(".name a", "href"),
              map: (url) => url.substring(1),
            ),
            "title": TextSelector.forScope(".name a"),
            "image": Attribute.forScope(".img img", "src"),
          }),
        ),
      ),
    );

    if (results == null) {
      return [];
    }

    return results.map(ContentSearchResult.fromJson).toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.https(host, "/$id");

    final scrapper = Scrapper(uri: uri);
    final result = await scrapper.scrap(
      Scope(
        scope: ".content",
        item: SelectorsToMap({
          "supplier": Const(name),
          "id": Const(id),
          "title": TextSelector.forScope(".anime_info_body h1"),
          "originalTitle":
              TextSelector.forScope(".anime_info_body p.other-name a"),
          "description": TextSelector.forScope(".anime_info_body .description"),
          "image": Attribute.forScope(
              ".anime_info_body .anime_info_body_bg img", "src"),
          "additionalInfo": Filter(
            Iterate(
              itemScope: '.anime_info_body p.type',
              item: TextSelector(inline: true),
            ),
            filter: (s) =>
                !s.startsWith("Plot Summary") && !s.startsWith("Other name"),
          ),
          "animeId": Attribute.forScope("#movie_id", "value")
        }),
      ),
    );

    if (result == null) {
      return null;
    }

    return AnitakuContentDetails.fromJson(result);
  }
}

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AnitakuContentDetails extends AbstractContentDetails
    with AsyncMediaItems {
  final String animeId;

  AnitakuContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.animeId,
  });

  factory AnitakuContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AnitakuContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => AnitakuMediaItemLoader(animeId);
}
