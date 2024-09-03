import 'package:cloud_hook/content_suppliers/extrators/source/two_embed.dart';
import 'package:test/test.dart';

void main() {
  test('two embed should return sources', () async {
    final sources = await TwoEmbedSourceLoader(imdb: "tt10676048").call();
    expect(sources, isNotEmpty);
  });
}
