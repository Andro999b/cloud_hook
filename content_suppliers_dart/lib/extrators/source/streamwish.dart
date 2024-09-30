import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/extrators/jwplayer/jwplayer.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';
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

    return JWPlayerSingleFileSourceLoader.lookupFile(
      unpackedScript,
      descriptionPrefix: descriptionPrefix,
    );
  }
}
