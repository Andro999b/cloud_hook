import 'package:content_suppliers_dart/extrators/source/multiembed.dart';
import 'package:test/test.dart';

void main() {
  test('multiembed should return sources', () async {
    final sources =
        await MultiembedSourceLoader(tmdb: 253, season: 1, episode: 1).call();
    expect(sources, isNotEmpty);
  });
}
