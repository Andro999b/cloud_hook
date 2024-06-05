// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TmdbSearchResponse _$TmdbSearchResponseFromJson(Map<String, dynamic> json) =>
    TmdbSearchResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => TmdbContentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
