import 'package:content_suppliers_dart/extrators/source/filemoon.dart';
import 'package:test/test.dart';

void main() async {
  test('filemoon should return sources', () async {
    final sources = await const FileMoonSourceLoader(
      url:
          "https://kerapoxy.cc/e/jlho8s4b3ei9/?sub.info=https%3A%2F%2Fvidsrc.to%2Fajax%2Fembed%2Fepisode%2FqvJmPsk%3D%2Fsubtitles&t=4xjRAfIuAVcIzQ%3D%3D&ads=0&src=vidsrc",
      referer: "https://vidsrc.to/embed/tv/tt0060028/1/19",
    ).call();
    expect(sources, isNotEmpty);
  });
}
