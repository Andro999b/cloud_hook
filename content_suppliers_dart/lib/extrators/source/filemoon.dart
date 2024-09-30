import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'package:js_unpack/js_unpack.dart';

class FileMoonSourceLoader implements ContentMediaItemSourceLoader {
  static final _fileRegExp = RegExp("file:\\s?['\"](?<file>[^\"]+)['\"]");

  final String url;
  final String referer;
  final String? despriptionPrefix;

  const FileMoonSourceLoader({
    required this.url,
    required this.referer,
    this.despriptionPrefix,
  });

  @override
  Future<List<ContentMediaItemSource>> call() async {
    final scrapper = Scrapper(
      uri: Uri.parse(url),
      headers: {"Referer": referer},
    );
    final script = await scrapper.scrap(
      TextSelector.forScope("script[data-cfasync='false']"),
    );

    if (script == null) {
      logger.w("[filemoon] script not found");
      return [];
    }

    if (!JsUnpack.detect(script)) {
      logger.w("[filemoon] cant unpack script");
      return [];
    }

    final unpackedScript = JsUnpack(script).unpack();

    final file = _fileRegExp.firstMatch(unpackedScript)?.namedGroup("file");

    if (file == null) {
      logger.w("[filemoon] file not found");
      return [];
    }

    return [
      SimpleContentMediaItemSource(
          description: despriptionPrefix ?? "Filemoon",
          link: parseUri(file),
          headers: {
            "Referer": referer,
          })
    ];
  }

  @override
  String toString() {
    return "FileMoonSourceLoader(url: $url, referer: $referer, despriptionPrefix: $despriptionPrefix)";
  }
}
