// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mangadex.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaDexSearchResponse _$MangaDexSearchResponseFromJson(
        Map<String, dynamic> json) =>
    MangaDexSearchResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => MangaDexContentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

MangaDexChaptersResponse _$MangaDexChaptersResponseFromJson(
        Map<String, dynamic> json) =>
    MangaDexChaptersResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => MangaDexChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

MangaDexChapter _$MangaDexChapterFromJson(Map<String, dynamic> json) =>
    MangaDexChapter(
      id: json['id'] as String,
      attributes: MangaDexChapterAttributes.fromJson(
          json['attributes'] as Map<String, dynamic>),
      relationships: json['relationships'] as List<dynamic>,
    );

MangaDexChapterAttributes _$MangaDexChapterAttributesFromJson(
        Map<String, dynamic> json) =>
    MangaDexChapterAttributes(
      title: json['title'] as String?,
      volume: json['volume'] as String? ?? 'No Volume',
      chapter: json['chapter'] as String,
      translatedLanguage: json['translatedLanguage'] as String,
      pages: (json['pages'] as num).toInt(),
    );
