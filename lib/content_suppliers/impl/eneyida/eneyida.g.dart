// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eneyida.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EneyidaContentDetails _$EneyidaContentDetailsFromJson(
        Map<String, dynamic> json) =>
    EneyidaContentDetails(
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
      iframe: json['iframe'] as String,
    );

Map<String, dynamic> _$EneyidaContentDetailsToJson(
        EneyidaContentDetails instance) =>
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
