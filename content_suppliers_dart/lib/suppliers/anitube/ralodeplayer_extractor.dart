import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/extrators/playerjs/playerjs.dart';
import 'package:content_suppliers_dart/extrators/utils.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ralodeplayer_extractor.g.dart';

@JsonSerializable(createToJson: false)
class RalodePlayerFile {
  final String code;
  final String name;

  RalodePlayerFile(this.code, this.name);

  factory RalodePlayerFile.fromJson(Map<String, dynamic> json) =>
      _$RalodePlayerFileFromJson(json);
}

class RalodePlayerExtractor implements ContentMediaItemLoader {
  static final _digitPattern = RegExp(r"(?<num>\d+)");
  static final _srcPattern = RegExp(r'src="(?<src>[^"]+)"');
  final String playerParams;
  final List<String> filterHosts;

  RalodePlayerExtractor(
    this.playerParams, {
    this.filterHosts = const ["ashdi", "tortuga", "moonanime", "monstro"],
  });

  @override
  FutureOr<List<ContentMediaItem>> call() {
    final decodeParams = json.decode("[$playerParams]");

    final playersNames = decodeParams[0] as List<dynamic>;
    final players = decodeParams[1] as List<dynamic>;

    Map<int, List<ContentMediaItemSourceLoader>> filesByNum = {};

    for (int i = 0; i < playersNames.length; i++) {
      final playerName = playersNames[i];
      final playerFiles = players[i] as List<dynamic>;
      for (final Map<String, dynamic> file in playerFiles) {
        final rpf = RalodePlayerFile.fromJson(file);

        final numStr = _digitPattern.firstMatch(rpf.name)?.namedGroup("num");
        final num = numStr == null ? 0 : int.parse(numStr);

        final files = filesByNum[num] ?? [];

        final iframe = _srcPattern.firstMatch(rpf.code)?.namedGroup("src");

        if (iframe == null) {
          logger.w("[AniTube - ralodeplayer] iframe not found");
          continue;
        }

        if (filterHosts.none((host) => iframe.contains(host))) {
          continue;
        }

        files.add(PlayerJSSourceLoader(
          iframe,
          SimpleUrlConvertStrategy(prefix: playerName),
        ));

        filesByNum[num] = files;
      }
    }

    return filesByNum.entries
        .mapIndexed(
          (i, e) => AsyncContentMediaItem(
            number: i,
            title: filesByNum.length == 1 ? "" : "${e.key} серія",
            sourcesLoader: AggSourceLoader(e.value),
          ),
        )
        .toList();
  }
}
