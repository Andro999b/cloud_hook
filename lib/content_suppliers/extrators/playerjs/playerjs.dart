import 'dart:collection';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/extractor.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playerjs.g.dart';

final _fileRegExp = RegExp("file:\\s?['\"](?<file>.+)['\"]");

@JsonSerializable()
class PlayerJSFile {
  final String title;
  final List<PlayerJSFile>? folder;
  final String? poster;
  final String? file;
  final String? subtitle;

  PlayerJSFile({
    required this.title,
    required this.folder,
    required this.poster,
    required this.file,
    required this.subtitle,
  });

  factory PlayerJSFile.fromJson(Map<String, dynamic> json) =>
      _$PlayerJSFileFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerJSFileToJson(this);
}

abstract class PlaylistConvertStrategy<R> {
  List<R> convert(Iterable<PlayerJSFile> playlist);
}

RegExp digitRegExp = RegExp(r'\d+');
typedef SeasonEpisodeId = Comparable Function(String season, String eposode);
Comparable defaultSeasonEpisodeId(String season, String episode) {
  return extractDigits(season) * 10000 + extractDigits(episode);
}

class DubSeasonEpisodeConvertStrategy
    extends PlaylistConvertStrategy<ContentMediaItem> {
  final SeasonEpisodeId seasonEpisodeId;

  DubSeasonEpisodeConvertStrategy({
    this.seasonEpisodeId = defaultSeasonEpisodeId,
  });

  @override
  List<ContentMediaItem> convert(Iterable<PlayerJSFile> playlist) {
    final mediaItems = SplayTreeMap<Comparable, SimpleContentMediaItem>();

    for (var dub in playlist) {
      dub.folder?.forEach((season) {
        season.folder?.forEach((episode) {
          final title = episode.title.trim();
          final section = season.title.trim();
          final id = defaultSeasonEpisodeId(section, title);

          final mediaItem = mediaItems.putIfAbsent(
            id,
            () => SimpleContentMediaItem(
              number: mediaItems.length,
              title: title,
              section: section,
              image: episode.poster,
              // ignore: prefer_const_literals_to_create_immutables
              sources: [],
            ),
          );

          mediaItem.sources.add(SimpleContentMediaItemSource(
            description: dub.title.trim(),
            link: Uri.parse(episode.file!),
          ));

          if (episode.subtitle != null) {
            mediaItem.sources.add(SimpleContentMediaItemSource(
              kind: FileKind.subtitle,
              description: dub.title.trim(),
              link: Uri.parse(episode.subtitle!),
            ));
          }
        });
      });
    }

    return mediaItems.values.toList();
  }
}

class DubConvertStrategy
    extends PlaylistConvertStrategy<ContentMediaItemSource> {
  @override
  List<ContentMediaItemSource> convert(Iterable<PlayerJSFile> playlist) {
    return playlist
        .map(
          (dub) => SimpleContentMediaItemSource(
            description: dub.title.trim(),
            link: Uri.parse(dub.file!),
          ),
        )
        .toList();
  }
}

class PlayerJSScrapper {
  final Uri uri;
  String? referer;

  PlayerJSScrapper({
    required this.uri,
    this.referer,
  });

  Future<List<ContentMediaItem>> scrap(
    PlaylistConvertStrategy<ContentMediaItem> convertStrategy,
  ) async {
    final fileEncodedJson = await loadPlayerJsFile();

    if (fileEncodedJson.startsWith("[{")) {
      final fileJson = jsonDecode(fileEncodedJson);
      Iterable fileListJson = fileJson as Iterable;

      final playerJsFiles = fileListJson.map((e) => PlayerJSFile.fromJson(e));

      return convertStrategy.convert(playerJsFiles);
    } else {
      return [
        SimpleContentMediaItem(
          number: 0,
          title: "",
          sources: [
            SimpleContentMediaItemSource(
              description: "Default",
              link: Uri.parse(fileEncodedJson),
            )
          ],
        )
      ];
    }
  }

  Future<List<ContentMediaItemSource>> scrapSources(
    PlaylistConvertStrategy<ContentMediaItemSource> convertStrategy,
  ) async {
    final fileEncodedJson = await loadPlayerJsFile();

    if (fileEncodedJson.startsWith("[{")) {
      final fileJson = jsonDecode(fileEncodedJson);
      Iterable fileListJson = fileJson as Iterable;

      final playerJsFiles = fileListJson.map((e) => PlayerJSFile.fromJson(e));

      return convertStrategy.convert(playerJsFiles);
    } else {
      return [
        SimpleContentMediaItemSource(
          description: "Default",
          link: Uri.parse(fileEncodedJson),
        )
      ];
    }
  }

  Future<String> loadPlayerJsFile() async {
    final response = await dio.get(uri.toString(),
        options: Options(headers: {
          ...defaultHeaders,
          if (referer != null) "Referer": referer!,
        }));

    final match = _fileRegExp.firstMatch(response.data);
    final fileEncodedJson = match?.namedGroup("file");

    if (fileEncodedJson == null) {
      throw Exception("PlayerJS file not found");
    }

    return fileEncodedJson;
  }
}

class PlayerJSExtractor implements ContentMediaItemExtractor {
  final PlaylistConvertStrategy<ContentMediaItem> convertStrategy;

  PlayerJSExtractor(this.convertStrategy);

  @override
  Future<List<ContentMediaItem>> extract(String iframe) {
    return PlayerJSScrapper(uri: Uri.parse(iframe)).scrap(convertStrategy);
  }
}
