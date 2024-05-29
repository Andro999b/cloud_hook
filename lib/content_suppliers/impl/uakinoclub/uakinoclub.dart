import 'package:cloud_hook/content_suppliers/content_extrators/dle_ajax_playlist.dart';
import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/impl/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uakinoclub.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class UAKinoContentDetails extends BaseContentDetails {
  UAKinoContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
  });

  factory UAKinoContentDetails.fromJson(Map<String, dynamic> json) =>
      _$UAKinoContentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UAKinoContentDetailsToJson(this);

  // ignore: prefer_final_fields
  Iterable<ContentMediaItem> _mediaItems = const [];

  @override
  Iterable<ContentMediaItem> get mediaItems => _mediaItems;

  @override
  MediaType get mediaType => MediaType.video;
}

class UAKinoClubSupplier extends ContentSupplier with DLEChannelsLoader {
  @override
  final host = "uakino.club";

  @override
  String get name => "UAKino";

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

  @override
  late final contentInfoSelector = Scope(
      scope: "#dle-content",
      item: IterateOverScope(
        itemScope: ".movie-item",
        item: SelectorsToMap(
          {
            "id": UrlId.forScope(".movie-title"),
            "supplier": Const(name),
            "image": Image.forScope(".movie-img > img", host),
            "title": Text.forScope(".movie-title"),
            "subtitle": Text.forScope(".full-quality")
          },
        ),
      ));

  @override
  Future<List<ContentSearchResult>> search(
      String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "/index.php");
    final scrapper = Scrapper(
      uri: uri,
      method: "post",
      headers: const {"Content-Type": "application/x-www-form-urlencoded"},
      form: {
        "do": "search",
        "subaction": "search",
        "from_page": 0,
        "story": query,
      },
    );

    final results = await scrapper.scrap(contentInfoSelector);

    return results
        .map(ContentSearchResult.fromJson)
        .whereNot(
            (e) => e.id.startsWith("news") || e.id.startsWith("franchise"))
        .toList();
  }

  @override
  Future<ContentDetails> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": Text.forScope(".solototle"),
          "originalTitle": Text.forScope(".origintitle"),
          "image": Image.forScope(".film-poster img", host),
          "description": Text.forScope("div[itemprop=description]"),
          "additionalInfo": Filter(
            IterateOverScope(
              itemScope: ".film-info > *",
              item: ConcatSelectors(
                [Text.forScope(".fi-label"), Text.forScope(".fi-desc")],
              ),
            ),
            filter: (text) => !text.startsWith("Доступно"),
          ),
          "similar": IterateOverScope(
            itemScope: ".related-items > .related-item > a",
            item: SelectorsToMap({
              "id": UrlId(),
              "supplier": Const(name),
              "title": Text.forScope(".full-movie-title"),
              "image": Image.forScope("img", host),
            }),
          ),
        },
      ),
    ));

    var details = UAKinoContentDetails.fromJson(result);

    // direct iframe
    final iframe = await scrapper.scrap(
      Attribute.forScope(".visible iframe", "src"),
    );

    if (iframe?.isNotEmpty == true) {
      details._mediaItems = [
        AsyncContentMediaItem(
          number: 0,
          title: "",
          sourcesLoader: () {
            return PlayerJSScrapper(uri: Uri.parse(iframe!))
                .scrapSources(DubConvertStrategy());
          },
        )
      ];

      return details;
    }

    // async iframe
    final newsId = id.split("/").last.split("-").first;
    details._mediaItems = await DLEAjaxPlaylistScrapper(
      uri: Uri.https(host, "/engine/ajax/playlists.php", {
        "news_id": newsId,
        "xfield": "playlist",
        "time": DateTime.now().millisecond.toString()
      }),
    ).scrap();

    return details;
  }

  @override
  final Map<String, String> channelsPath = {
    "Новинки": "/page/",
    "Фільми": "/filmy/page/",
    "Серіали": "/seriesss/page/",
    "Аніме": "/animeukr/page/",
    "Мультфільми": "/cartoon/page/",
    "Мультсеріали": "/cartoon/cartoonseries/page/"
  };

  @override
  Set<String> get channels => channelsPath.keys.toSet();

  @override
  Set<String> get defaultChannels => const {"Новинки"};
}
