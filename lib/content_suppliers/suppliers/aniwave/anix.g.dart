// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anix.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnixContentDetails _$AnixContentDetailsFromJson(Map<String, dynamic> json) =>
    AnixContentDetails(
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
