import 'dart:async';

import 'package:cloud_hook/content_suppliers/extrators/jwplayer/jwplayer.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:js_unpack/js_unpack.dart';

class StreamwishSourceLoader implements ContentMediaItemSourceLoader {
  final String url;
  final String? referer;
  final String? descriptionPrefix;

  StreamwishSourceLoader({
    required this.url,
    this.referer,
    this.descriptionPrefix,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final scrapper = Scrapper(uri: Uri.parse(url), headers: {
      "Referer": referer,
    });

    final packedScript = (await scrapper.scrap(Filter(
      Iterate(itemScope: "script", item: TextSelector()),
      filter: (s) => s.contains("p,a,c,k,e,d"),
    )))
        ?.firstOrNull;

    if (packedScript == null) {
      logger.w("[streamwish] p,a,c,k,e,d not found");
      return [];
    }

    final unpackedScript = JsUnpack(packedScript).unpack();

    return JWPlayerSingleFileSourceLoader.lookuFile(
      unpackedScript,
      descriptionPrefix: descriptionPrefix,
    );
  }
}
