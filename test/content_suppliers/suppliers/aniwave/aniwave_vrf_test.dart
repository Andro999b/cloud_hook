import 'package:cloud_hook/content_suppliers/suppliers/aniwave/aniwave_vrf.dart';
import 'package:test/test.dart';

void main() {
  test("Should generate correct vrf", () async {
    final vrf = await aniwaveEncryptVRF("17027");
    expect(vrf, equals("cE9mRHFqLVdvNXN3MmFSTQ=="));
  });

  test("Should decrypt url", () async {
    final url = await aniwaveDecryptURL(
        "cEpfZnhqbnptSUZNei1JQ0R2THlyaEJuckdYeU1zQUk5Z2NCX1ViRE84eG92OUZlZFBVbHppb3VMX21Gc0wtRDl4YkhKUTZ1ME5iSHVuejRoaDdndC1Ddnl0NmRLNldDb25oa2FKZGJyWGJyS0NYeldpUVJvZz09");
    expect(url, equals("https://megaf.cc/e/07ynm7?t=4xjSDfUjAFQOyg=="));
  });
}
