import 'dart:async';
import 'dart:convert';

import 'package:content_suppliers_api/model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'mangadex.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mangadex_item_source.g.dart';

@JsonSerializable(createToJson: false)
class MangaDexServerResponse {
  final String baseUrl;
  final MangaDexServerChapterResponse chapter;

  MangaDexServerResponse({
    required this.baseUrl,
    required this.chapter,
  });

  factory MangaDexServerResponse.fromJson(Map<String, dynamic> json) =>
      _$MangaDexServerResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MangaDexServerChapterResponse {
  final String hash;
  final List<String> data;
  final List<String> dataSaver;

  MangaDexServerChapterResponse({
    required this.hash,
    required this.data,
    required this.dataSaver,
  });

  factory MangaDexServerChapterResponse.fromJson(Map<String, dynamic> json) =>
      _$MangaDexServerChapterResponseFromJson(json);
}

class MangaDexItemSource implements MangaMediaItemSource {
  final String id;
  @override
  final String description;
  @override
  final int pageNambers;

  List<ImageProvider<Object>>? _pages;

  MangaDexItemSource({
    required this.id,
    required this.description,
    required this.pageNambers,
  });

  @override
  FileKind get kind => FileKind.manga;

  @override
  FutureOr<List<ImageProvider<Object>>> allPages() async {
    return _pages ??= await _loadPages();
  }

  Future<List<ImageProvider<Object>>> _loadPages() async {
    try {
      final chapterServerUri = Uri.https(
        MangaDexSupllier.siteHost,
        "/at-home/server/$id",
      );

      final chapterServerRes = await http.get(
        chapterServerUri,
        headers: {
          "User-Agent": MangaDexSupllier.userAgent,
        },
      );

      final server = MangaDexServerResponse.fromJson(
        json.decode(chapterServerRes.body),
      );

      final serverUri = Uri.parse(server.baseUrl);

      return Stream.fromIterable(server.chapter.data)
          .asyncMap((fileName) async {
        final fileUrl = serverUri.replace(
          path: "/data/${server.chapter.hash}/$fileName",
        );
        return CachedNetworkImageProvider(fileUrl.toString());
      }).toList();
    } catch (error, stackTrace) {
      logger.e(
        "[MangaDex] Failed to load pages",
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
