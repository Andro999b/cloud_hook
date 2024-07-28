import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/suppliers/mangadex/mangadex_item_source.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mangadex.g.dart';

const _coverArtHost = "https://uploads.mangadex.org/covers";
const _supplierName = "MangaDex";

@immutable
class MangaDexContentInfo extends ContentSearchResult {
  const MangaDexContentInfo({
    required super.id,
    required super.supplier,
    required super.image,
    required super.title,
    super.secondaryTitle,
  });

  factory MangaDexContentInfo.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final attributes = json["attributes"] as Map<String, dynamic>;
    final relationships = json["relationships"] as List<dynamic>;
    final coverFileName = _lookupCoverFile(relationships);

    return MangaDexContentInfo(
      id: id,
      supplier: _supplierName,
      image: "$_coverArtHost/$id/$coverFileName.512.jpg",
      title: attributes["title"]["en"],
    );
  }
}

@immutable
class MangaDexContentDetails extends AbstractContentDetails {
  @override
  final List<ContentMediaItem> mediaItems;

  const MangaDexContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaItems,
  });

  @override
  MediaType get mediaType => MediaType.manga;

  factory MangaDexContentDetails.ctreate(
    List<ContentMediaItem> mediaItems,
    Map<String, dynamic> json,
  ) {
    final id = json["id"];
    final attributes = json["attributes"] as Map<String, dynamic>;
    final originalLanguage = attributes["originalLanguage"];
    final relationships = json["relationships"] as List<dynamic>;
    final coverFileName = _lookupCoverFile(relationships);

    final altTitles = attributes["altTitles"] as List<dynamic>;
    final originalTitle = altTitles.firstWhereOrNull(
        (t) => t[originalLanguage] != null)?[originalLanguage];

    final description = attributes["description"]["en"];
    final title = attributes["title"]["en"];

    final author = _lookupAuthor(relationships);
    final year = attributes["year"];
    final status = attributes["status"];

    final tags = attributes["tags"] as List<dynamic>;
    final genres = tags
        .where((t) => t["attributes"]["group"] == "genre")
        .map((t) => t["attributes"]["name"]["en"])
        .join(", ");

    return MangaDexContentDetails(
      id: json["id"],
      supplier: _supplierName,
      title: title,
      originalTitle: originalTitle,
      image: "$_coverArtHost/$id/$coverFileName",
      description: description,
      additionalInfo: [
        "Author: $author",
        "Year: $year",
        "Status: $status",
        "Genres: $genres",
      ],
      similar: const [],
      mediaItems: mediaItems,
    );
  }
}

class MangaDexSupllier extends ContentSupplier {
  static const host = "api.mangadex.org";
  static const userAgent = "Cloud Hook APP";

  final Dio _dio;

  MangaDexSupllier()
      : _dio = Dio()
          // ..interceptors.add(LogInterceptor(responseBody: false))
          ..options.headers["User-Agent"] = userAgent
          ..options.sendTimeout = const Duration(seconds: 30)
          ..options.receiveTimeout = const Duration(seconds: 30);

  @override
  String get name => _supplierName;

  @override
  Set<ContentType> get supportedTypes => const {ContentType.manga};

  @override
  Set<ContentLanguage> get supportedLanguages => const {
        ContentLanguage.english,
        ContentLanguage.ukrainian,
      };

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final uri = Uri.https(host, "/manga", {
      "title": query,
      "includes[]": "cover_art",
    });

    final res = await _dio.getUri(uri);

    return MangaDexSearchResponse.fromJson(res.data).data;
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final uri = Uri.https(host, "/manga/$id", {
      "includes[]": ["cover_art", "author"],
    });

    try {
      final res = await _dio.getUri(uri);
      final mediaItems = await _createMediaItems(id);

      return MangaDexContentDetails.ctreate(mediaItems, res.data["data"]);
    } catch (e, stackTrace) {
      logger.e("[MangaDex] Fail to load $id", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<List<ContentMediaItem>> _createMediaItems(String id) async {
    const limit = 500;
    var requestsLeft = 30; // 15000 max
    var lastOffset = 0;

    final mediaItems = <String, SimpleContentMediaItem>{};

    while (requestsLeft > 0) {
      final uri = Uri.https(host, "/manga/$id/feed", {
        "includes[]": "scanlation_group",
        "order[volume]": "asc",
        "order[chapter]": "asc",
        "offset": lastOffset.toString(),
        "limit": limit.toString(),
      });
      final res = await _dio.getUri(uri);
      final chaptersRes = MangaDexChaptersResponse.fromJson(res.data);

      for (final chapter in chaptersRes.data) {
        final attributes = chapter.attributes;
        final relationships = chapter.relationships;
        final key = "${attributes.volume}_${attributes.chapter}";

        SimpleContentMediaItem mediaItem = mediaItems.putIfAbsent(
          key,
          () => SimpleContentMediaItem(
            number: mediaItems.length,
            title: "Chapter ${attributes.chapter}",
            section: attributes.volume,
            // ignore: prefer_const_literals_to_create_immutables
            sources: [],
          ),
        );

        final translation = _lookupScanlationGroup(relationships);

        if (translation != null && attributes.pages > 0) {
          mediaItem.sources.add(MangaDexItemSource(
            id: chapter.id,
            description: "[${attributes.translatedLanguage}] $translation",
            pageNambers: attributes.pages,
          ));
        }
      }

      if (chaptersRes.limit + chaptersRes.offset >= chaptersRes.total) {
        break;
      }

      lastOffset += limit;
      requestsLeft--;
    }

    return mediaItems.values.toList();
  }
}

String _lookupCoverFile(List<dynamic> relationships) {
  final coverArt = relationships.firstWhere((r) => r["type"] == "cover_art");
  final coverFileName = coverArt["attributes"]["fileName"]!;
  return coverFileName;
}

String _lookupAuthor(List<dynamic> relationships) {
  final author = relationships.firstWhere((r) => r["type"] == "author");
  final authorName = author["attributes"]["name"]!;
  return authorName;
}

String? _lookupScanlationGroup(List<dynamic> relationships) {
  final scanlationGroup =
      relationships.firstWhereOrNull((r) => r["type"] == "scanlation_group");

  if (scanlationGroup == null) {
    return null;
  }

  final scanlationGroupName = scanlationGroup["attributes"]["name"]!;
  return scanlationGroupName;
}

@JsonSerializable(createToJson: false)
class MangaDexSearchResponse {
  final List<MangaDexContentInfo> data;
  final int limit;
  final int offset;
  final int total;

  MangaDexSearchResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory MangaDexSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MangaDexSearchResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MangaDexChaptersResponse {
  final List<MangaDexChapter> data;
  final int limit;
  final int offset;
  final int total;

  MangaDexChaptersResponse({
    required this.data,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory MangaDexChaptersResponse.fromJson(Map<String, dynamic> json) =>
      _$MangaDexChaptersResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MangaDexChapter {
  final String id;
  final MangaDexChapterAttributes attributes;
  final List<dynamic> relationships;

  MangaDexChapter({
    required this.id,
    required this.attributes,
    required this.relationships,
  });

  factory MangaDexChapter.fromJson(Map<String, dynamic> json) =>
      _$MangaDexChapterFromJson(json);
}

@JsonSerializable(createToJson: false)
class MangaDexChapterAttributes {
  final String? title;
  @JsonKey(defaultValue: "No Volume")
  final String volume;
  final String chapter;
  final String translatedLanguage;
  final int pages;

  MangaDexChapterAttributes({
    this.title,
    required this.volume,
    required this.chapter,
    required this.translatedLanguage,
    required this.pages,
  });

  factory MangaDexChapterAttributes.fromJson(Map<String, dynamic> json) =>
      _$MangaDexChapterAttributesFromJson(json);
}
