import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:js_unpack/js_unpack.dart';

class FileMoonSourceLoader {
  static final _fileRegExp = RegExp("file:\\s?['\"](?<file>[^\"]+)['\"]");

  final String url;
  final String referer;

  const FileMoonSourceLoader({
    required this.url,
    required this.referer,
  });

  Future<List<ContentMediaItemSource>> call() async {
    final scrapper = Scrapper(uri: url, headers: {"Referer": referer});
    final script = await scrapper.scrap(
      Text.forScope("script[data-cfasync='false']"),
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
        description: "Filemoon",
        link: Uri.parse(file),
      )
    ];
  }
}
