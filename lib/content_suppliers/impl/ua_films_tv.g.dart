// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ua_films_tv.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UAFilmsTVContentDetails _$UAFilmsTVContentDetailsFromJson(
        Map<String, dynamic> json) =>
    UAFilmsTVContentDetails(
      id: json['id'] as String,
      supplier: json['supplier'] as String,
      title: json['title'] as String,
      originalTitle: json['originalTitle'] as String,
      image: json['image'] as String,
      description: json['description'] as String,
      additionalInfo: (json['additionalInfo'] as List<dynamic>)
          .map((e) =>
              ContentDetailsAdditionalInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      similar: (json['similar'] as List<dynamic>)
          .map((e) => ContentSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      iframe: json['iframe'] as String,
    );

Map<String, dynamic> _$UAFilmsTVContentDetailsToJson(
        UAFilmsTVContentDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplier': instance.supplier,
      'title': instance.title,
      'originalTitle': instance.originalTitle,
      'image': instance.image,
      'description': instance.description,
      'additionalInfo': instance.additionalInfo,
      'similar': instance.similar,
      'iframe': instance.iframe,
    };
