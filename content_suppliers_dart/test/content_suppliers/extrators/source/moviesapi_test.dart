import 'package:content_suppliers_dart/extrators/source/moviesapi.dart';

import 'package:test/test.dart';

void main() async {
  test('moviesapi should return sources', () async {
    final sources = await MoviesapiSourceLoader(tmdb: 385687).call();
    expect(sources, isNotEmpty);
  });
}
