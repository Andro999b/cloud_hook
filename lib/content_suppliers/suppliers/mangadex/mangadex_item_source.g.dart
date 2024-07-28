// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mangadex_item_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaDexServerResponse _$MangaDexServerResponseFromJson(
        Map<String, dynamic> json) =>
    MangaDexServerResponse(
      baseUrl: json['baseUrl'] as String,
      chapter: MangaDexServerChapterResponse.fromJson(
          json['chapter'] as Map<String, dynamic>),
    );

MangaDexServerChapterResponse _$MangaDexServerChapterResponseFromJson(
        Map<String, dynamic> json) =>
    MangaDexServerChapterResponse(
      hash: json['hash'] as String,
      data: (json['data'] as List<dynamic>).map((e) => e as String).toList(),
      dataSaver:
          (json['dataSaver'] as List<dynamic>).map((e) => e as String).toList(),
    );
