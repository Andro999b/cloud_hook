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

enum ContentLanguage {
  english("en"),
  ukrainian("uk");

  final String code;

  const ContentLanguage(this.code);
}

enum MediaType {
  video,
  manga,
}

abstract class ContentSupplier {
  String get name;
  Set<String> get channels => const {};
  Set<String> get defaultChannels => const {};
  Set<ContentType> get supportedTypes => const {};
  Set<ContentLanguage> get supportedLanguages => const {};
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async =>
      const [];

  Future<List<ContentInfo>> loadChannel(
    String channel, {
    int page = 0,
  }) async =>
      const [];
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
  FutureOr<Uri> get link;
  Map<String, String>? get headers;
}

mixin ContentDetails {
  String get id;
  String get supplier;
  String get title;
  String? get originalTitle;
  String get image;
  String get description;
  MediaType get mediaType;
  List<String> get additionalInfo;
  List<ContentInfo> get similar;
  FutureOr<Iterable<ContentMediaItem>> get mediaItems;
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
  final String? originalTitle;
  @override
  final String image;
  @override
  final String description;
  @override
  @JsonKey(defaultValue: [])
  final List<String> additionalInfo;
  @override
  @JsonKey(defaultValue: [])
  final List<ContentSearchResult> similar;
  @override
  MediaType get mediaType => MediaType.video;

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

abstract class BasicContentMediaItem extends Equatable with ContentMediaItem {
  @override
  final int number;
  @override
  final String title;
  @override
  final String? section;
  @override
  final String? image;

  const BasicContentMediaItem({
    required this.number,
    required this.title,
    this.section,
    this.image,
  });

  @override
  List<Object?> get props => [number];
}

typedef ContentItemMediaSourceLoader = Future<List<ContentMediaItemSource>>
    Function();

// ignore: must_be_immutable
class AsyncContentMediaItem extends BasicContentMediaItem {
  List<ContentMediaItemSource>? _cachedSources;

  @override
  Future<List<ContentMediaItemSource>> get sources async =>
      _cachedSources ??= await sourcesLoader();

  final ContentItemMediaSourceLoader sourcesLoader;

  AsyncContentMediaItem({
    required super.number,
    required super.title,
    required this.sourcesLoader,
    super.section,
    super.image,
  });
}

@immutable
class SimpleContentMediaItem extends BasicContentMediaItem {
  @override
  final List<ContentMediaItemSource> sources;

  const SimpleContentMediaItem({
    required super.number,
    required super.title,
    required this.sources,
    super.section,
    super.image,
  });
}

@immutable
class SimpleContentMediaItemSource extends Equatable
    with ContentMediaItemSource {
  @override
  final String description;
  @override
  final Uri link;
  @override
  final Map<String, String>? headers;

  const SimpleContentMediaItemSource({
    required this.description,
    required this.link,
    this.headers,
  });

  @override
  List<Object?> get props => [link, headers];
}

typedef ContentItemMediaSourceLinkLoader = Future<Uri> Function();

// ignore: must_be_immutable
class AsyncContentMediaItemSource extends Equatable
    with ContentMediaItemSource {
  @override
  final String description;
  @override
  final Map<String, String>? headers;

  Uri? _linkLoader;

  ContentItemMediaSourceLinkLoader linkLoader;

  @override
  Future<Uri> get link async => _linkLoader ??= await linkLoader();

  AsyncContentMediaItemSource({
    required this.description,
    required this.linkLoader,
    this.headers,
  });

  @override
  List<Object?> get props => [link, headers];
}
