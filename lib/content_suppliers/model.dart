import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum ContentType { movie, anime, cartoon, tvShow, manga }

abstract interface class ContentSupplier {
  String get name;
  Set<ContentType> get supportedTypes;
  Future<Iterable<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  );
  Future<ContentDetails> detailsById(String id);
}

mixin ContentInfo {
  // TODO: Add content type?
  String get id;
  String get supplier;
  String get title;
  String? get subtitle;
  String get image;
}

mixin ContentMediaItem {
  int get number;
  String get title;
  List<ContentMediaItemSource> get sources;
  String? get section;
  String? get image;
}

mixin ContentMediaItemSource {
  String get type;
  String get description;
  Uri get link;
  Map<String, String>? get headers;
}

mixin ContentDetails {
  String get id;
  String get supplier;
  String get title;
  String get oroginalTitle;
  String get image;
  String get description;
  Iterable<ContentDetailsAdditionalInfo> get additionalInfo;
  Iterable<ContentInfo> get similar;
  Future<Iterable<ContentMediaItem>> get mediaItems;
}

@JsonSerializable()
class ContentSearchResult with ContentInfo {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String image;
  @override
  final String title;
  @override
  final String? subtitle;

  ContentSearchResult({
    required this.id,
    required this.supplier,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  factory ContentSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ContentSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ContentSearchResultToJson(this);
}

abstract class BaseContentDetails with ContentDetails {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  final String oroginalTitle;
  @override
  final String image;
  @override
  final String description;
  @override
  final List<ContentDetailsAdditionalInfo> additionalInfo;
  @override
  final List<ContentSearchResult> similar;

  BaseContentDetails({
    required this.id,
    required this.supplier,
    required this.title,
    required this.oroginalTitle,
    required this.image,
    required this.description,
    required this.additionalInfo,
    required this.similar,
  });
}

@JsonSerializable()
class ContentDetailsAdditionalInfo {
  final String name;
  final String value;

  ContentDetailsAdditionalInfo({required this.name, required this.value});

  factory ContentDetailsAdditionalInfo.fromJson(Map<String, dynamic> json) =>
      _$ContentDetailsAdditionalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDetailsAdditionalInfoToJson(this);
}

class SimpleContentMediaItemSource with ContentMediaItemSource {
  @override
  final String type;
  @override
  final String description;
  @override
  final Uri link;
  @override
  final Map<String, String>? headers;

  SimpleContentMediaItemSource({
    required this.type,
    required this.description,
    required this.link,
    this.headers,
  });
}

class SimpleContentMediaItem with ContentMediaItem {
  @override
  final int number;
  @override
  final String title;
  @override
  final List<ContentMediaItemSource> sources;
  @override
  String? section;
  @override
  String? image;

  SimpleContentMediaItem({
    required this.number,
    required this.title,
    required this.sources,
    this.section,
    this.image,
  });
}
