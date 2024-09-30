import 'package:content_suppliers_dart/extrators/source/megacloud.dart';

import 'package:test/test.dart';

void main() async {
  test('megacloud [encrypted] should return sources', () async {
    final sources = await const MegacloudSourceLoader(
      url: "https://megacloud.tv/embed-2/e-1/SHt74e9Bh5yc?k=1",
    ).call();
    expect(sources, isNotEmpty);
  });
}
