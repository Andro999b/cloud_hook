import 'dart:async';

import 'package:cloud_hook/content_suppliers/extrators/hunter_unpack.dart';
import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';

class MultiembedSourceLoader implements ContentMediaItemSourceLoader {
  static const baseUrl = "https://multiembed.mov";
  static final _hunterRegExp = RegExp(
      r'eval\(function\(h,u,n,t,e,r\).*?}\("(?<h>\w+)",(?<u>\d+),"(?<n>\w+)",(?<t>\d+),(?<e>\d+),(?<r>\d+)\)\)');

  final int tmdb;
  final int? episode;
  final int? season;

  MultiembedSourceLoader({
    required this.tmdb,
    this.episode,
    this.season,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    String url;

    if (episode == null) {
      url = "$baseUrl/directstream.php?video_id=$tmdb&tmdb=1";
    } else {
      url =
          "$baseUrl/directstream.php?video_id=$tmdb&tmdb=1&s=$season&e=$episode";
    }

    final res = await dio.get(
      url,
      options: Options(
        headers: {
          ...defaultHeaders,
          "Referer": baseUrl,
        },
      ),
    );

    var match = _hunterRegExp.firstMatch(res.data);

    if (match == null) {
      logger.w("[multiembed] hunter code not found");
      return [];
    }

    final unpackedScript = hunterUnpack(
      match.namedGroup("h")!,
      match.namedGroup("u")!, // unused
      match.namedGroup("n")!,
      int.parse(match.namedGroup("t")!),
      int.parse(match.namedGroup("e")!),
      int.parse(match.namedGroup("r")!), // unused
    );

    final file =
        playerJSFileRegExp.firstMatch(unpackedScript)?.namedGroup("file");

    if (file == null) {
      logger.w("[multiembed] file not found");
      return [];
    }

    return [
      SimpleContentMediaItemSource(
        description: "Multiembed",
        link: parseUri(file),
      ),
    ];
  }

  @override
  String toString() =>
      "MultiembedSourceLoader(tmdb: $tmdb, episode: $episode, season: $season)";
}
