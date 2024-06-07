// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TmdbSearchResponse _$TmdbSearchResponseFromJson(Map<String, dynamic> json) =>
    _TmdbSearchResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => TmdbContentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

_TmdbSeason _$TmdbSeasonFromJson(Map<String, dynamic> json) => _TmdbSeason(
      (json['episodes'] as List<dynamic>)
          .map((e) => _TmdbEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

_TmdbEpisode _$TmdbEpisodeFromJson(Map<String, dynamic> json) => _TmdbEpisode(
      seasonNumber: (json['season_number'] as num).toInt(),
      episodeNumber: (json['episode_number'] as num).toInt(),
      name: json['name'] as String,
      stillPath: json['still_path'] as String?,
    );
