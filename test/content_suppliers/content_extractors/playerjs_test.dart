import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:test/test.dart';

void main() {
  group("PlayerJS", () {
    test("Should return media items for tv show", () async {
      final uri = Uri.parse("https://ashdi.vip/serial/3110");
      final playerjs = PlayerJSScrapper(
        uri: uri,
        convertStrategy: DubSeasonEpisodeConvertStrategy(),
      );

      await playerjs.scrap();
    });
    test("Should return media items for movie", () async {
      final uri = Uri.parse("https://tortuga.wtf/vod/97077");
      final playerjs = PlayerJSScrapper(
        uri: uri,
        convertStrategy: DubSeasonEpisodeConvertStrategy(),
      );

      await playerjs.scrap();
    });
  });
}
