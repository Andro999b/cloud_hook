import 'dart:collection';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playerjs.g.dart';

final playerJSFileRegExp = RegExp("file:\\s?['\"](?<file>.+)['\"]");

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

  factory PlayerJSFile.fromJson(Map<String, dynamic> json) => _$PlayerJSFileFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerJSFileToJson(this);
}

abstract class PlaylistConvertStrategy<R> {
  List<R> convert(String playlist) {
    if (playlist.startsWith("[{")) {
      final fileJson = jsonDecode(playlist);
      Iterable fileListJson = fileJson as Iterable;

      final playerJsFiles = fileListJson.map((e) => PlayerJSFile.fromJson(e));
      return convertPlayerJsFiles(playerJsFiles);
    } else {
      return convertSingleFile(playlist);
    }
  }

  List<R> convertPlayerJsFiles(Iterable<PlayerJSFile> playlist);

  List<R> convertSingleFile(String playlist);
}

typedef SeasonEpisodeId = Comparable Function(String season, String eposode);

class DubSeasonEpisodeConvertStrategy extends PlaylistConvertStrategy<ContentMediaItem> {
  static final RegExp digitRegExp = RegExp(r'\d+');
  static Comparable defaultSeasonEpisodeId(String season, String episode) {
    return extractDigits(season) * 10000 + extractDigits(episode);
  }

  final SeasonEpisodeId seasonEpisodeId;
  final subtitleRegExp = RegExp(r"^\[(?<label>[^\]]+)\](?<url>.*)");

  DubSeasonEpisodeConvertStrategy({
    this.seasonEpisodeId = DubSeasonEpisodeConvertStrategy.defaultSeasonEpisodeId,
  });

  @override
  List<ContentMediaItem> convertPlayerJsFiles(Iterable<PlayerJSFile> playlist) {
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
            link: parseUri(episode.file!),
          ));

          if (episode.subtitle?.isNotEmpty == true) {
            var subMath = subtitleRegExp.firstMatch(episode.subtitle!);

            mediaItem.sources.add(SimpleContentMediaItemSource(
              kind: FileKind.subtitle,
              description: subMath?.namedGroup("label") ?? dub.title.trim(),
              link: parseUri(subMath?.namedGroup("url") ?? episode.subtitle!),
            ));
          }
        });
      });
    }

    return mediaItems.values.toList();
  }

  @override
  List<ContentMediaItem> convertSingleFile(String playlist) {
    return [
      SimpleContentMediaItem(
        number: 0,
        title: "",
        sources: [
          SimpleContentMediaItemSource(
            description: "Default",
            link: parseUri(playlist),
          )
        ],
      )
    ];
  }
}

class DubConvertStrategy extends PlaylistConvertStrategy<ContentMediaItemSource> {
  @override
  List<ContentMediaItemSource> convertPlayerJsFiles(
    Iterable<PlayerJSFile> playlist,
  ) {
    return playlist
        .map(
          (dub) => SimpleContentMediaItemSource(
            description: dub.title.trim(),
            link: parseUri(dub.file!),
          ),
        )
        .toList();
  }

  @override
  List<ContentMediaItemSource> convertSingleFile(String playlist) {
    return [
      SimpleContentMediaItemSource(
        description: "Default",
        link: parseUri(playlist),
      )
    ];
  }
}

class SimpleUrlConvertStrategy extends PlaylistConvertStrategy<ContentMediaItemSource> {
  final String prefix;

  SimpleUrlConvertStrategy({this.prefix = ""});

  @override
  List<ContentMediaItemSource> convertPlayerJsFiles(
    Iterable<PlayerJSFile> playlist,
  ) {
    return playlist.expand((file) => convertSingleFile(file.file!) + convertSubtitle(file.subtitle)).toList();
  }

  @override
  List<ContentMediaItemSource> convertSingleFile(String playlist) {
    return playlist
        .split(",")
        .map(parseUrlWithPrefix)
        .map(
          (e) => SimpleContentMediaItemSource(
            description: e.$1,
            link: parseUri(e.$2),
          ),
        )
        .toList();
  }

  List<ContentMediaItemSource> convertSubtitle(String? subtitle) {
    if (subtitle == null) {
      return [];
    }

    return subtitle
        .split(",")
        .map(parseUrlWithPrefix)
        .map(
          (e) => SimpleContentMediaItemSource(
            kind: FileKind.subtitle,
            description: e.$1,
            link: parseUri(e.$2),
          ),
        )
        .toList();
  }

  (String, String) parseUrlWithPrefix(String file) {
    if (!file.startsWith("[")) {
      return (prefix, file);
    }

    final splitIndex = file.indexOf("]");

    return (
      file.substring(0, splitIndex + 1) + prefix,
      file.substring(splitIndex + 1),
    );
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

    return convertStrategy.convert(fileEncodedJson);
  }

  Future<List<ContentMediaItemSource>> scrapSources(
    PlaylistConvertStrategy<ContentMediaItemSource> convertStrategy,
  ) async {
    final fileEncodedJson = await loadPlayerJsFile();

    return convertStrategy.convert(fileEncodedJson);
  }

  Future<String> loadPlayerJsFile() async {
    final response = await dio.get(uri.toString(),
        options: Options(headers: {
          ...defaultHeaders,
          if (referer != null) "Referer": referer!,
        }));

    final match = playerJSFileRegExp.firstMatch(response.data);
    final fileEncodedJson = match?.namedGroup("file");

    if (fileEncodedJson == null) {
      throw Exception("PlayerJS file not found");
    }

    return fileEncodedJson;
  }
}

class PlayerJSExtractor implements ContentMediaItemLoader {
  final PlaylistConvertStrategy<ContentMediaItem> convertStrategy;
  final String iframe;

  PlayerJSExtractor(this.iframe, this.convertStrategy);

  @override
  Future<List<ContentMediaItem>> call() {
    return PlayerJSScrapper(uri: parseUri(iframe)).scrap(convertStrategy);
  }

  @override
  String toString() {
    return "PlayerJSExtractor($iframe)";
  }
}

class PlayerJSSourceLoader implements ContentMediaItemSourceLoader {
  final PlaylistConvertStrategy<ContentMediaItemSource> convertStrategy;
  final String iframe;

  PlayerJSSourceLoader(this.iframe, this.convertStrategy);

  @override
  Future<List<ContentMediaItemSource>> call() {
    return PlayerJSScrapper(uri: parseUri(iframe)).scrapSources(convertStrategy);
  }

  @override
  String toString() {
    return "PlayerJSSourceLoader($iframe)";
  }
}
