import 'dart:async';
import 'dart:collection';

import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dle_ajax_playlist_extractor.g.dart';

@JsonSerializable(createToJson: false)
class Label {
  final String lable;
  final String id;

  Label(this.lable, this.id);

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
}

@JsonSerializable(createToJson: false)
class EpisodeVideo {
  final String id;
  final String name;
  final String file;

  EpisodeVideo(this.id, this.name, this.file);

  late final Set<String> labelIds = {
    id.substring(0, 3),
    if (id.length >= 5) id.substring(0, 5),
  };

  factory EpisodeVideo.fromJson(Map<String, dynamic> json) => _$EpisodeVideoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PlaylistResults {
  final List<EpisodeVideo> videos;
  final List<Label> lables;
  final Map<int, List<EpisodeVideo>> _byEpisodeNumber = SplayTreeMap<int, List<EpisodeVideo>>();

  PlaylistResults(this.videos, this.lables) {
    for (var v in videos) {
      final id = extractDigits(v.name);
      if (id > 0) {
        (_byEpisodeNumber[id] ??= []).add(v);
      }
    }
  }

  Map<int, List<EpisodeVideo>> get byEpisodeNumber => _byEpisodeNumber;

  late final Map<String, String> labelById = {for (var e in lables) e.id: e.lable};

  String videoLable(Iterable<String> lableIds) => lableIds.map((e) => labelById[e]).nonNulls.join(" ");

  factory PlaylistResults.fromJson(Map<String, dynamic> json) => _$PlaylistResultsFromJson(json);
}

class DLEAjaxPLaylistExtractor implements ContentMediaItemLoader {
  final Uri playlistUri;
  final List<String> filterHosts;
  final String referer;

  DLEAjaxPLaylistExtractor(this.playlistUri, this.referer,
      {this.filterHosts = const ["ashdi", "tortuga", "moonanime", "monstro"]});

  @override
  FutureOr<List<ContentMediaItem>> call() async {
    final url = playlistUri.toString();

    final res = await dio.get(url,
        options: Options(headers: {
          ...defaultHeaders,
          "X-Requested-With": "XMLHttpRequest",
          "Referer": referer,
        }));

    final result = await Scrapper.scrapFragment(
      res.data["response"] as String,
      ".playlists-player",
      SelectorsToMap({
        "lables": Filter(
          Iterate(
            itemScope: ".playlists-lists > .playlists-items li",
            item: SelectorsToMap({
              "id": Attribute("data-id"),
              "lable": TextSelector(),
            }),
          ),
          filter: (e) => e["id"] != null,
        ),
        "videos": Iterate(
          itemScope: ".playlists-videos li",
          item: SelectorsToMap({
            "id": Attribute("data-id"),
            "name": TextSelector(),
            "file": Attribute("data-file"),
          }),
        )
      }),
    );

    if (result == null) {
      return [];
    }

    try {
      final playlist = PlaylistResults.fromJson(result);

      return playlist.byEpisodeNumber.entries
          .mapIndexed(
            (i, entry) => AsyncContentMediaItem(
              number: i,
              title: playlist.byEpisodeNumber.length == 1 ? "" : "${entry.key} серія",
              sourcesLoader: AggSourceLoader(
                entry.value
                    // filter passable videos hostings
                    .where(
                      (video) => filterHosts.any(
                        (host) => video.file.contains(host),
                      ),
                    )
                    .map(
                      (video) => PlayerJSSourceLoader(
                        video.file,
                        SimpleUrlConvertStrategy(
                          prefix: playlist.videoLable(video.labelIds),
                        ),
                      ),
                    ),
              ),
            ),
          )
          .toList();
    } catch (e, stack) {
      logger.e("[AniTube] Failed to parse playlist", error: e, stackTrace: stack);
      rethrow;
    }
  }
}
