// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aniwave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AniWaveContentDetails _$AniWaveContentDetailsFromJson(
        Map<String, dynamic> json) =>
    AniWaveContentDetails(
      id: json['id'] as String,
      supplier: json['supplier'] as String,
      title: json['title'] as String,
      originalTitle: json['originalTitle'] as String?,
      image: json['image'] as String,
      description: json['description'] as String,
      additionalInfo: (json['additionalInfo'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      similar: (json['similar'] as List<dynamic>?)
              ?.map((e) =>
                  ContentSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mediaId: json['mediaId'] as String,
    );
