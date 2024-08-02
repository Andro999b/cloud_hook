import 'package:cloud_hook/content_suppliers/extrators/source/streamwish.dart';

import 'package:test/test.dart';

void main() async {
  test('streamwish should return sources 1', () async {
    final sources = await StreamwishSourceLoader(
      url: "https://awish.pro/e/az75rzu52lip",
      referer: "https://anitaku.pe/oban-star-racers-episode-20",
    ).call();
    expect(sources, isNotEmpty);
  });

  test('streamwish should return sources 2', () async {
    final sources = await StreamwishSourceLoader(
      url: "https://alions.pro/v/d3yenleunv5f",
      referer: "https://anitaku.pe/oban-star-racers-episode-20",
    ).call();
    expect(sources, isNotEmpty);
  });
}
