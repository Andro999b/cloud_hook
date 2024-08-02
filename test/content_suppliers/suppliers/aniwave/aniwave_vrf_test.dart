import 'package:cloud_hook/content_suppliers/suppliers/aniwave/aniwave_vrf.dart';
import 'package:test/test.dart';

void main() {
  test("Should generate correct vrf", () async {
    final vrf = await aniwaveVRF("14161");
    expect(vrf, equals("u--S"));
  });

  test("Should decrypt url", () async {
    final url = await aniwaveDecryptURL(
        "biRg7iG4vs8U2hI5GelW2e3k6NsU8vwNI0eR2Ib2EWXDt8XDI5fJUZbKTOOrScMfpGcSsQq9hgm-J2xEuSzUx9PxCs6EnIwt5Xs-DA==");
    expect(url,
        equals("https://vid2a41.site/e/GQP475713P93?t=4xjRAPEkBVUKyQ%3D%3D"));
  });
}
