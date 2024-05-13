import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum ContentType {
  movie,
  anime,
  cartoon,
  series,
  manga,
}

enum MediaType {
  video,
  manga,
}

abstract interface class ContentSupplier {
  String get name;
  List<String> get channels;
  Set<ContentType> get supportedTypes;
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  );
  Future<SupplierChannels> loadChannels(Set<String> channels);
  Future<ContentDetails> detailsById(String id);
}

mixin ContentInfo {
  String get id;
  String get supplier;
  String get title;
  String? get subtitle;
  String get image;
}

mixin ContentMediaItem {
  int get number;
  String get title;
  FutureOr<List<ContentMediaItemSource>> get sources;
  String? get section;
  String? get image;
}

mixin ContentMediaItemSource {
  String get description;
  Uri get link;
  Map<String, String>? get headers;
}

mixin ContentDetails {
  String get id;
  String get supplier;
  String get title;
  String get originalTitle;
  String get image;
  String get description;
  MediaType get mediaType;
  List<ContentDetailsAdditionalInfo> get additionalInfo;
  List<ContentInfo> get similar;
  Future<Iterable<ContentMediaItem>> get mediaItems;
}

@immutable
@JsonSerializable()
class ContentSearchResult extends Equatable with ContentInfo {
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

  const ContentSearchResult({
    required this.id,
    required this.supplier,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  factory ContentSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ContentSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ContentSearchResultToJson(this);

  @override
  List<Object?> get props => [id, supplier, image, title, subtitle];
}

abstract class BaseContentDetails extends Equatable with ContentDetails {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  final String originalTitle;
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
    required this.originalTitle,
    required this.image,
    required this.description,
    required this.additionalInfo,
    required this.similar,
  });

  @override
  List<Object?> get props => [
        id,
        supplier,
        title,
        originalTitle,
        image,
        description,
        additionalInfo,
        similar
      ];
}

@immutable
@JsonSerializable()
class ContentDetailsAdditionalInfo extends Equatable {
  final String name;
  final String value;

  const ContentDetailsAdditionalInfo({required this.name, required this.value});

  factory ContentDetailsAdditionalInfo.fromJson(Map<String, dynamic> json) =>
      _$ContentDetailsAdditionalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDetailsAdditionalInfoToJson(this);

  @override
  List<Object?> get props => [name, value];
}

class SimpleContentMediaItemSource extends Equatable
    with ContentMediaItemSource {
  @override
  final String description;
  @override
  final Uri link;
  @override
  final Map<String, String>? headers;

  SimpleContentMediaItemSource({
    required this.description,
    required this.link,
    this.headers,
  });

  @override
  List<Object?> get props => [description, link, headers];
}

@immutable
class SimpleContentMediaItem extends Equatable with ContentMediaItem {
  @override
  final int number;
  @override
  final String title;
  @override
  final List<ContentMediaItemSource> sources;
  @override
  final String? section;
  @override
  final String? image;

  const SimpleContentMediaItem({
    required this.number,
    required this.title,
    required this.sources,
    this.section,
    this.image,
  });

  @override
  List<Object?> get props => [number, title, sources, section, image];
}

typedef SupplierChannels = Map<String, List<ContentInfo>>;
