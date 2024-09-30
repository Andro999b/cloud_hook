import 'package:content_suppliers_dart/utils.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async {
  test("should extract digits from string", () {
    final num = extractDigits("Серія 1046");
    expect(num, equals(1046));
  });
}
