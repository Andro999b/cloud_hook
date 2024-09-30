import 'package:content_suppliers_dart/extrators/source/gogostream.dart';
import 'package:test/test.dart';

void main() async {
  test('gogostreamshould should return sources', () async {
    final sources = await GogoStreamSourceLoader(
      url:
          "https://s3taku.com/embedplus?id=MjgyMTY=&token=UWpYCXpSeQOCumKz7v9wmg&expires=1722671534",
    ).call();
    expect(sources, isNotEmpty);
  });
}
