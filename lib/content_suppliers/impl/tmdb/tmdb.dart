import 'dart:async';

import 'package:cloud_hook/app_secrets.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/two_embed.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmdb.g.dart';

@JsonSerializable(createToJson: false)
class TmdbSearchResponse {
  final List<TmdbContentInfo> results;

  TmdbSearchResponse({required this.results});

  factory TmdbSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TmdbSearchResponseFromJson(json);
}

class TmdbContentInfo implements ContentInfo {
  @override
  final String id;
  @override
  final String supplier = "TMDB";
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String image;

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

class TmdbContentDetails extends BaseContentDetails {
  @override
  final List<ContentMediaItem> mediaItems;

  const TmdbContentDetails({
    required super.id,
    super.supplier = "TMDB",
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaItems,
  });

  factory TmdbContentDetails.fromJson(String id, Map<String, dynamic> json) {
    final title = json["name"] ?? json["title"];
    final originalTitle = json["original_title"];
    final imdbId = json["external_ids"]?["imdb_id"] ?? json["imdb_id"];

    List<ContentMediaItem> mediaItems = [];
    if (json["seasons"] == null) {
      mediaItems.add(
        _createMediaItem(imdbId: imdbId),
      );
    } else {
      List<dynamic> seasons = json["seasons"];
      int count = 0;
      seasons.forEachIndexed((seasonNumber, season) {
        final seasonNumber = season["season_number"];
        final int episodeCount = season["episode_count"];

        if (seasonNumber == 0) {
          return;
        }

        for (int episodeNumber = 0;
            episodeNumber < episodeCount;
            episodeNumber++) {
          mediaItems.add(
            _createMediaItem(
              id: count++,
              imdbId: imdbId,
              season: seasonNumber,
              seasonName: season["name"],
              episode: episodeNumber + 1,
            ),
          );
        }
      });
    }

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
      similar: TmdbSearchResponse.fromJson(json["recommendations"]).results,
      mediaItems: mediaItems,
    );
  }

  static AsyncContentMediaItem _createMediaItem({
    int id = 0,
    String? imdbId,
    int? season,
    String? seasonName,
    int? episode,
  }) {
    return AsyncContentMediaItem(
      number: id,
      section: season != null ? "Season $season" : seasonName,
      title: episode != null ? "Episode $episode" : "",
      sourcesLoader: aggSourceLoader([
        if (imdbId != null)
          TwoEmbedSourceLoader(
            imdbId: imdbId,
            season: season,
            episode: episode,
          ),
      ]),
    );
  }
}

String _posterImage(String path) {
  if (path.startsWith("/")) return "https://image.tmdb.org/t/p/w500$path";
  return path;
}

String _originalPosterImage(String path) {
  if (path.startsWith("/")) return "https://image.tmdb.org/t/p/original$path";
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
  String get name => "TMDB";

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

    return TmdbContentDetails.fromJson(id, res.data);
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

    return TmdbSearchResponse.fromJson(res.data).results;
  }
}
