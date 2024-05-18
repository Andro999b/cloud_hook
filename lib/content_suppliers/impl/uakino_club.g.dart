// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uakino_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UAKinoClubContentDetails _$UAKinoClubContentDetailsFromJson(
        Map<String, dynamic> json) =>
    UAKinoClubContentDetails(
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
    );

Map<String, dynamic> _$UAKinoClubContentDetailsToJson(
        UAKinoClubContentDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplier': instance.supplier,
      'title': instance.title,
      'originalTitle': instance.originalTitle,
      'image': instance.image,
      'description': instance.description,
      'additionalInfo': instance.additionalInfo,
      'similar': instance.similar,
    };
