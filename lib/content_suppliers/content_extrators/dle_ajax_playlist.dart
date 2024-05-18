import 'dart:convert';

import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'dle_ajax_playlist.g.dart';

@JsonSerializable()
class _AjaxPlaylistItem {
  final String id;
  final String text;
  final String link;
  final String? voice;

  _AjaxPlaylistItem({
    required this.id,
    required this.text,
    required this.link,
    required this.voice,
  });

  factory _AjaxPlaylistItem.fromJson(Map<String, dynamic> data) =>
      _$AjaxPlaylistItemFromJson(data);
}

class DLEAjaxPlaylistScrapper {
  final Uri uri;

  DLEAjaxPlaylistScrapper({required this.uri});

  Future<List<ContentMediaItem>> scrap() async {
    final res = await http.get(uri, headers: defaultHeaders);

    final playlistItems = await Scrapper.scrapFragment(
          jsonDecode(res.body)["response"],
          ".playlists-player",
          IterateOverScope(
            itemScope: ".playlists-videos li[data-id]",
            item: SelectorsToMap({
              "id": Attribute("data-id"),
              "text": Text(),
              "voice": Attribute("data-voice"),
              "link": Attribute("data-file")
            }),
          ),
        ) ??
        [];

    if (playlistItems.isEmpty) {
      return [];
    }

    final groupedById =
        playlistItems.map(_AjaxPlaylistItem.fromJson).groupListsBy((e) => e.id);

    if (groupedById.length == 1) {
      return [
        SimpleContentMediaItem(
          number: 0,
          title: "",
          sources: groupedById.values.first.map(_extractMediaSources).toList(),
        )
      ];
    }

    return groupedById.entries.mapIndexed((index, e) {
      return SimpleContentMediaItem(
        number: index,
        title: e.value.first.text,
        sources: e.value.map(_extractMediaSources).toList(),
      );
    }).toList();
  }

  ContentMediaItemSource _extractMediaSources(_AjaxPlaylistItem item) {
    return AsyncContentMediaItemSource(
      description: item.voice?.isNotEmpty == true ? item.voice! : "Default",
      linkLoader: () async {
        final playerLink = Uri.parse(item.link);
        final fileUrl =
            await PlayerJSScrapper(uri: playerLink).loadPlayerJsFile();

        return Uri.parse(fileUrl);
      },
    );
  }
}
