// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hianime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HianimeContentDetails _$HianimeContentDetailsFromJson(
        Map<String, dynamic> json) =>
    HianimeContentDetails(
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
      mediaId: json['mediaId'] as String,
    );
