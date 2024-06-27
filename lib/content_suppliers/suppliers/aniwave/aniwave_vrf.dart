import 'dart:convert';

import 'package:simple_rc4/simple_rc4.dart';

const vrfKeys = ["tGn6kIpVXBEUmqjD", "LUyDrL4qIxtIxOGs"];

String aniwaveVRF(String data) {
  final encryptKey = vrfKeys[0];

  final chiper = RC4(encryptKey);

  List<int> vrf = chiper.encodeBytes(utf8.encode(data));
  vrf = utf8.encode(base64Url.encode(vrf));
  vrf = utf8.encode(base64.encode(vrf));

  const adds = [-2, -4, -5, 6, 2, -3, 3, 6];
  for (var i = 0; i < vrf.length; i++) {
    vrf[i] = vrf[i] + adds[i % adds.length];
  }

  return base64.encode(vrf.reversed.toList());
}

String aniwaveDecryptURL(String data) {
  final decryptKey = vrfKeys[1];

  final chiper = RC4(decryptKey);
  final List<int> decrypted = chiper.encodeBytes(base64.decode(data));

  return Uri.decodeComponent(utf8.decode(decrypted));
}
