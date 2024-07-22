import 'dart:ffi';

import 'package:cloud_hook/content_suppliers/extrators/source/multiembed.dart';
import 'package:test/test.dart';

void main() {
  test('multiembed should return sources', () async {
    final sources = await MultiembedSourceLoader(tmdb: 253, season: 1, episode: 1).call();
    expect(sources, isNotEmpty);
  });
}
