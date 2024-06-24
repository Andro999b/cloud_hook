import 'package:cloud_hook/utils/text.dart';
import 'package:test/test.dart';

void main() async {
  test("should extract digits from string", () {
    final num = extractDigits("Серія 1046");
    expect(num, equals(1046));
  });
}
