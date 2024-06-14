import 'dart:async';

import 'package:cloud_hook/app_secrets.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/moviesapi.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/two_embed.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/vidsrcto.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmdb.g.dart';

const supplierName = "TMDB";

class TmdbContentInfo implements ContentInfo {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String image;
  @override
  String get supplier => supplierName;

  TmdbContentInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  factory TmdbContentInfo.fromJson(Map<String, dynamic> json) {
    final title = json["name"] ?? json["title"];
    final originalTitle = json["original_title"];

    return TmdbContentInfo(
      id: "${json["media_type"]}/${json["id"]}",
      title: title,
      subtitle: title != originalTitle ? originalTitle : null,
      image:
          json["poster_path"] != null ? _posterImage(json["poster_path"]) : "",
    );
  }
}

class TmdbContentDetails implements ContentDetails {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? originalTitle;
  @override
  final String image;
  @override
  final String description;
  @override
  @JsonKey(defaultValue: [])
  final List<String> additionalInfo;
  @override
  final List<ContentInfo> similar;
  @override
  final List<ContentMediaItem> mediaItems;
  @override
  String get supplier => supplierName;

  @override
  MediaType get mediaType => MediaType.video;

  const TmdbContentDetails({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.image,
    required this.description,
    required this.additionalInfo,
    required this.similar,
    required this.mediaItems,
  });

  factory TmdbContentDetails.fromJson(
    String id,
    List<ContentMediaItem> mediaItems,
    Map<String, dynamic> json,
  ) {
    final title = json["name"] ?? json["title"];
    final originalTitle = json["original_title"];

    return TmdbContentDetails(
      id: id,
      title: title,
      originalTitle: originalTitle,
      image: json["poster_path"] != null
          ? _originalPosterImage(json["poster_path"])
          : "",
      description: json["overview"],
      additionalInfo: [
        json["vote_average"].toString(),
        if (json["release_date"] != null)
          "Realise date: ${json["release_date"]}",
        if (json["first_air_date"] != null)
          "First air date: ${json["first_air_date"]}",
        if (json["last_air_date"] != null)
          "Last air date: ${json["last_air_date"]}",
        if (json["next_air_date"] != null)
          "Next air date: ${json["next_air_date"]}",
        if (json["genres"] != null)
          "Genres: ${json["genres"].map((e) => e["name"]).join(", ")}",
        if (json["production_countries"] != null)
          "Country: ${json["production_countries"].map((e) => e["name"]).join(", ")}",
      ],
      similar: _TmdbSearchResponse.fromJson(json["recommendations"]).results,
      mediaItems: mediaItems,
    );
  }
}

String _posterImage(String path) {
  if (path.startsWith("/")) return "http://image.tmdb.org/t/p/w342$path";
  return path;
}

String _originalPosterImage(String path) {
  if (path.startsWith("/")) {
    return "http://image.tmdb.org/t/p/original$path";
  }
  return path;
}

class TmdbSupplier extends ContentSupplier {
  static const secretName = "tmdb";
  static const api = "api.themoviedb.org";

  final Dio dio;

  TmdbSupplier()
      : dio = Dio()
          ..options.headers["Authorization"] =
              "Bearer ${AppSecrets.getString("tmdb")}"
  // ..interceptors.add(LogInterceptor(
  //   requestBody: true,
  //   responseBody: true,
  //   // logPrint: logger.i,
  // ))
  ;

  @override
  String get name => supplierName;

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.series,
        ContentType.cartoon,
        ContentType.anime,
      };

  @override
  Set<ContentLanguage> get supportedLanguages =>
      const {ContentLanguage.english};

  @override
  Future<ContentDetails> detailsById(String id) async {
    final uri = Uri.https(api, "/3/$id", {
      "append_to_response": "external_ids,recommendations",
    });

    final res = await dio.get(uri.toString());

    final json = res.data;
    final tmdb = json["id"];
    final imdb = json["external_ids"]?["imdb_id"] ?? json["imdb_id"];

    List<ContentMediaItem> mediaItems = [];
    if (json["seasons"] == null) {
      mediaItems.add(
        _createMediaItem(json["id"], imdb: imdb),
      );
    } else {
      List<dynamic> seasons = json["seasons"];

      final episodes = await Stream.fromIterable(seasons)
          .where((s) => s["season_number"] != 0)
          .asyncMap((s) async {
            var seasonUri =
                Uri.https(api, "/3/$id/season/${s["season_number"]}");
            final seasonRes = await dio.get(seasonUri.toString());
            final season = _TmdbSeason.fromJson(seasonRes.data);

            return season.episodes;
          })
          .expand((e) => e)
          .toList();

      mediaItems = episodes
          .mapIndexed((index, ep) => _createMediaItem(
                tmdb,
                id: index,
                imdb: imdb,
                season: ep.seasonNumber,
                seasonName: "Season ${ep.seasonNumber}",
                episode: ep.episodeNumber,
                episodeName: "${ep.episodeNumber}. ${ep.name}",
                episodePoster:
                    ep.stillPath != null ? _posterImage(ep.stillPath!) : null,
              ))
          .toList();
    }

    return TmdbContentDetails.fromJson(id, mediaItems, res.data);
  }

  AsyncContentMediaItem _createMediaItem(
    int tmdb, {
    int id = 0,
    String? imdb,
    int? season,
    String? seasonName,
    int? episode,
    String? episodeName,
    String? episodePoster,
  }) {
    return AsyncContentMediaItem(
      number: id,
      section: seasonName,
      title: episodeName ?? "",
      image: episodePoster,
      sourcesLoader: aggSourceLoader([
        MoviesapiSourceLoader(tmdb: tmdb, season: season, episode: episode),
        if (imdb != null) ...[
          VidSrcToSourceLoader(imdb: imdb, season: season, episode: episode),
          TwoEmbedSourceLoader(imdb: imdb, season: season, episode: episode),
        ]
      ]),
    );
  }

  @override
  Future<List<ContentInfo>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(
      api,
      "/3/search/multi",
      {
        "query": query,
        "page": "1",
        "language": "en-US",
      },
    );

    final res = await dio.get(uri.toString());

    return _TmdbSearchResponse.fromJson(res.data).results;
  }
}

@JsonSerializable(createToJson: false)
class _TmdbSearchResponse {
  final List<TmdbContentInfo> results;

  _TmdbSearchResponse({required this.results});

  factory _TmdbSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class _TmdbSeason {
  final List<_TmdbEpisode> episodes;

  _TmdbSeason(this.episodes);

  factory _TmdbSeason.fromJson(Map<String, dynamic> json) =>
      _$TmdbSeasonFromJson(json);
}

@JsonSerializable(createToJson: false)
class _TmdbEpisode {
  @JsonKey(name: "season_number")
  final int seasonNumber;
  @JsonKey(name: "episode_number")
  final int episodeNumber;
  final String name;
  @JsonKey(name: "still_path")
  final String? stillPath;

  _TmdbEpisode({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.name,
    this.stillPath,
  });

  factory _TmdbEpisode.fromJson(Map<String, dynamic> json) =>
      _$TmdbEpisodeFromJson(json);
}
