import 'dart:convert';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

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

abstract class PlaylistConvertStrategy {
  Iterable<ContentMediaItem> convert(Iterable<PlayerJSFile> playlist);
}

class DubSeasonEpisodeConvertStrategy extends PlaylistConvertStrategy {
  @override
  Iterable<ContentMediaItem> convert(Iterable<PlayerJSFile> playlist) {
    final mediaItems = <Record, SimpleContentMediaItem>{};

    for (var dub in playlist) {
      dub.folder?.forEach((season) {
        season.folder?.forEach((episode) {
          final title = episode.title.trim();
          final section = season.title.trim();
          final id = (section, title);

          final mediaItem = mediaItems.putIfAbsent(
            id,
            () => SimpleContentMediaItem(
              number: mediaItems.length,
              title: episode.title.trim(),
              section: season.title.trim(),
              image: episode.poster,
              sources: [],
            ),
          );

          mediaItem.sources.add(SimpleContentMediaItemSource(
            type: "",
            description: dub.title.trim(),
            link: Uri.parse(episode.file!),
          ));
        });
      });
    }

    return mediaItems.values;
  }
}

class PlayerJSScrapper {
  final Uri uri;
  final PlaylistConvertStrategy convertStrategy;
  String? referer;

  PlayerJSScrapper({
    required this.uri,
    required this.convertStrategy,
    this.referer,
  });

  Future<Iterable<ContentMediaItem>> scrap() async {
    final response = await http.get(uri, headers: {
      ...defaultHeaders,
      if (referer != null) "Referer": referer!,
    });

    final match = _fileRegExp.firstMatch(response.body);
    final fileEncodedJson = match?.namedGroup("file");

    if (fileEncodedJson == null) {
      throw Exception("PlayerJS file not found");
    }

    return decodePlaylist(fileEncodedJson);
  }

  Iterable<ContentMediaItem> decodePlaylist(String filesEncodedJson) {
    // TODO: decrypt

    if (filesEncodedJson.startsWith("[{")) {
      final fileJson = jsonDecode(filesEncodedJson);
      Iterable fileListJson = fileJson as Iterable;

      final playerJsFiles = fileListJson.map((e) => PlayerJSFile.fromJson(e));

      return convertStrategy.convert(playerJsFiles);
    } else {
      return _singleFile(filesEncodedJson);
    }
  }

  Iterable<ContentMediaItem> _singleFile(String fileJson) {
    return [
      SimpleContentMediaItem(
        number: 0,
        title: "",
        sources: [
          SimpleContentMediaItemSource(
            type: "",
            description: "",
            link: Uri.parse(fileJson),
          )
        ],
      )
    ];
  }
}
