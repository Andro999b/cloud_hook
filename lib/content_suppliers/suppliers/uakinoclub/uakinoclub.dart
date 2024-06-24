import 'package:cloud_hook/content_suppliers/extrators/dle/dle_ajax_playlist_extractor.dart';
import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/suppliers/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uakinoclub.g.dart';

@JsonSerializable(createToJson: false)
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
  String get name => "UAKinoClub";

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
  late final contentInfoSelector = Iterate(
    itemScope: "#dle-content .movie-item",
    item: SelectorsToMap(
      {
        "id": UrlId.forScope(".movie-title"),
        "supplier": Const(name),
        "image": Image.forScope(".movie-img > img", host),
        "title": TextSelector.forScope(".movie-title"),
        "secondaryTitle": TextSelector.forScope(".full-quality")
      },
    ),
  );

  @override
  Future<List<ContentSearchResult>> search(
      String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "/index.php");
    final scrapper = Scrapper(
      uri: uri.toString(),
      method: "post",
      headers: const {"Content-Type": "application/x-www-form-urlencoded"},
      form: {
        "do": "search",
        "subaction": "search",
        "from_page": 0,
        "story": query,
      },
    );

    final results = await scrapper.scrap(contentInfoSelector) ?? [];

    return results
        .map(ContentSearchResult.fromJson)
        .whereNot(
            (e) => e.id.startsWith("news") || e.id.startsWith("franchise"))
        .toList();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html").toString());

    final result = await scrapper.scrap(Scope(
      scope: "#dle-content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextSelector.forScope(".solototle"),
          "originalTitle": TextSelector.forScope(".origintitle"),
          "image": Image.forScope(".film-poster img", host),
          "description": TextSelector.forScope("div[itemprop=description]"),
          "additionalInfo": Filter(
            Iterate(
              itemScope: ".film-info > *",
              item: Concat.selectors(
                [
                  TextSelector.forScope(".fi-label"),
                  TextSelector.forScope(".fi-desc")
                ],
              ),
            ),
            filter: (text) => !text.startsWith("Доступно"),
          ),
          "similar": Iterate(
            itemScope: ".related-items > .related-item > a",
            item: SelectorsToMap({
              "id": UrlId(),
              "supplier": Const(name),
              "title": TextSelector.forScope(".full-movie-title"),
              "image": Image.forScope("img", host),
            }),
          ),
        },
      ),
    ));

    if (result == null) {
      return Future.value(null);
    }

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
            return PlayerJSScrapper(uri: parseUri(iframe!))
                .scrapSources(DubConvertStrategy());
          },
        )
      ];

      return details;
    }

    // async iframe
    final newsId = id.split("/").last.split("-").first;
    details._mediaItems = await DLEAjaxPLaylistExtractor(
      Uri.https(host, "/engine/ajax/playlists.php", {
        "news_id": newsId,
        "xfield": "playlist",
        "time": DateTime.now().millisecond.toString()
      }),
    ).call();

    return details;
  }

  @override
  final Map<String, String> channelsPath = {
    "Новинки": "/page/",
    "Фільми": "/filmy/page/",
    "Серіали": "/series/page/",
    "Аніме": "/animeukr/page/",
    "Мультфільми": "/cartoon/page/",
    "Мультсеріали": "/cartoon/cartoonseries/page/"
  };

  @override
  Set<String> get defaultChannels => const {"Новинки"};
}
