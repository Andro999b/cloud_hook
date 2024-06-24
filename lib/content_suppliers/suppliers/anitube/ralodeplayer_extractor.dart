import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/extractor.dart';
import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
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

class RalodePlayerExtractor implements ContentMediaItemExtractor {
  static final _digitPattern = RegExp(r"(?<num>\d+)");
  static final _srcPattern = RegExp(r'src="(?<src>[^"]+)"');
  final String playerParams;

  RalodePlayerExtractor(this.playerParams);

  @override
  FutureOr<List<ContentMediaItem>> call() {
    final decodeParams = json.decode("[$playerParams]");

    final playersNames = decodeParams[0] as List<dynamic>;
    final players = decodeParams[1] as List<dynamic>;

    Map<int, List<ContentItemMediaSourceLoader>> filesByNum = {};

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
            sourcesLoader: aggSourceLoader(e.value),
          ),
        )
        .toList();
  }
}
