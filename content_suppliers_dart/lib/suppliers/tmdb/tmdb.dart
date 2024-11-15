import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_dart/extrators/source/moviesapi.dart';
import 'package:content_suppliers_dart/extrators/source/multiembed.dart';
import 'package:content_suppliers_dart/extrators/source/two_embed.dart';
import 'package:content_suppliers_dart/extrators/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmdb.g.dart';

const _supplierName = "TMDB";

class TmdbSupplier extends ContentSupplier {
  static const secretName = "tmdb";
  static const api = "api.themoviedb.org";

  final Dio dio;

  TmdbSupplier({required String secret})
      : dio = Dio()
          ..options.headers["Authorization"] = "Bearer $secret"
          ..options.sendTimeout = const Duration(seconds: 30)
          ..options.receiveTimeout = const Duration(seconds: 30)
  // ..interceptors.add(LogInterceptor(
  //   requestBody: true,
  //   responseBody: true,
  //   // logPrint: logger.i,
  // ))
  ;

  @override
  String get name => _supplierName;

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.series,
        ContentType.cartoon,
        ContentType.anime,
      };

  @override
  Set<ContentLanguage> get supportedLanguages => const {ContentLanguage.en};

  @override
  Future<ContentDetails> detailsById(String id) async {
    final uri = Uri.https(api, "/3/$id", {
      "append_to_response": "external_ids,credits,recommendations",
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
      sourcesLoader: AggSourceLoader([
        MoviesapiSourceLoader(tmdb: tmdb, season: season, episode: episode),
        MultiembedSourceLoader(tmdb: tmdb, season: season, episode: episode),
        if (imdb != null) ...[
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
      {"query": query, "page": "1", "language": "en-US"},
    );

    final res = await dio.get(uri.toString());

    return _TmdbSearchResponse.fromJson(res.data).results;
  }

  final Map<String, String> _channelsPath = const {
    "Trending": "/trending/all/day",
    "Popular Movies": "/movie/popular",
    "Popular TV Shows": "/tv/popular",
    "Top Rated Movies": "/movie/top_rated",
    "Top Rated TV Shows": "/tv/top_rated",
    "Latest Movies": "/movie/latest",
    "Latest TV Shows": "/movie/latest",
    "On The Air TV Shows": "/tv/on_the_air"
  };

  @override
  Set<String> get channels => _channelsPath.keys.toSet();

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async {
    final path = _channelsPath[channel];

    if (path == null) {
      return [];
    }

    final uri = Uri.https(
      api,
      "/3/$path",
      {"page": page.toString(), "language": "en-US"},
    );

    final res = await dio.get(uri.toString());

    // add media type
    final results = res.data["results"] as List<dynamic>;
    if (path.contains("movie")) {
      for (var e in results) {
        e["media_type"] = "movie";
      }
    } else if (path.contains("tv")) {
      for (var e in results) {
        e["media_type"] = "tv";
      }
    }

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

class TmdbContentInfo implements ContentInfo {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? secondaryTitle;
  @override
  final String image;
  @override
  String get supplier => _supplierName;

  TmdbContentInfo({
    required this.id,
    required this.title,
    required this.secondaryTitle,
    required this.image,
  });

  factory TmdbContentInfo.fromJson(Map<String, dynamic> json) {
    final title = json["name"] ?? json["title"];
    final originalTitle = json["original_title"];
    final type = json["media_type"];

    return TmdbContentInfo(
      id: "$type/${json["id"]}",
      title: title,
      secondaryTitle: title != originalTitle ? originalTitle : null,
      image:
          json["poster_path"] != null ? _posterImage(json["poster_path"]) : "",
    );
  }
}

@immutable
class TmdbContentDetails extends AbstractContentDetails {
  @override
  final List<ContentMediaItem> mediaItems;

  const TmdbContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaItems,
  });

  factory TmdbContentDetails.fromJson(
    String id,
    List<ContentMediaItem> mediaItems,
    Map<String, dynamic> json,
  ) {
    final title = json["name"] ?? json["title"];
    final originalTitle = json["original_title"];
    final recommendations = json["recommendations"];

    return TmdbContentDetails(
      id: id,
      supplier: _supplierName,
      title: title,
      originalTitle: originalTitle,
      image: json["poster_path"] != null
          ? _originalPosterImage(json["poster_path"])
          : "",
      description: json["overview"],
      additionalInfo: [
        json["vote_average"].toString(),
        if (json["created_by"] != null)
          "Created by: ${json["created_by"].map((e) => e["name"]).join(", ")}",
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
        if (json["credits"]?["cast"] != null)
          "Cast: ${json["credits"]["cast"].map((e) => e["name"]).join(", ")}",
      ],
      similar: recommendations != null
          ? _TmdbSearchResponse.fromJson(recommendations).results
          : [],
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
