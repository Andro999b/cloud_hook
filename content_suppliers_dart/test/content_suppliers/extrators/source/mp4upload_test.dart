import 'package:content_suppliers_dart/extrators/source/mp4upload.dart';

import 'package:test/test.dart';

void main() async {
  test('mp4upload should return sources', () async {
    final sources = await MP4UploadSourceLoader(
      url:
          "https://www.mp4upload.com/embed-ykgekw52unm8.html?t=4xjRAPAmA1IAzg%3D%3D&autostart=true",
    ).call();
    expect(sources, isNotEmpty);
  });
}
