// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentSearchResult _$ContentSearchResultFromJson(Map<String, dynamic> json) =>
    ContentSearchResult(
      id: json['id'] as String,
      supplier: json['supplier'] as String,
      image: json['image'] as String,
      title: json['title'] as String,
      secondaryTitle: json['secondaryTitle'] as String?,
    );

Map<String, dynamic> _$ContentSearchResultToJson(
        ContentSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplier': instance.supplier,
      'image': instance.image,
      'title': instance.title,
      'secondaryTitle': instance.secondaryTitle,
    };
