import 'package:cloud_hook/content_suppliers/extrators/source/moviesapi.dart';

import 'package:test/test.dart';

void main() async {
  test('moviesapi should return sources', () async {
    final sources = await MoviesapiSourceLoader(tmdb: 958196).call();
    expect(sources, isNotEmpty);
  });
}
