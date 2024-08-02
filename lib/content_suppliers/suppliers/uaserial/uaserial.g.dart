// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uaserial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UASerialContentDetails _$UASerialContentDetailsFromJson(
        Map<String, dynamic> json) =>
    UASerialContentDetails(
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
      similar: json['similar'] == null
          ? []
          : ContentSearchResult.fromJsonList(json['similar'] as List),
      iframe: json['iframe'] as String,
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => UASerialEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

UASerialEpisode _$UASerialEpisodeFromJson(Map<String, dynamic> json) =>
    UASerialEpisode(
      name: json['name'] as String,
      iframe: json['iframe'] as String,
    );
