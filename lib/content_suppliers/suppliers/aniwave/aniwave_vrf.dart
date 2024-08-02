import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';
import 'package:simple_rc4/simple_rc4.dart';

// load separetelly

Future<String> aniwaveVRF(String data) async {
  final vrfKeys = (await MultiApiKeys.fetch()).aniwave!;
  final encryptKey = vrfKeys[0];

  final chiper = RC4(encryptKey);

  List<int> vrf = chiper.encodeBytes(utf8.encode(data));
  return base64Url.encode(vrf);
  // vrf = utf8.encode(base64Url.encode(vrf));
  // vrf = utf8.encode(base64.encode(vrf));

  // const adds = [-2, -4, -5, 6, 2, -3, 3, 6];
  // for (var i = 0; i < vrf.length; i++) {
  //   vrf[i] = vrf[i] + adds[i % adds.length];
  // }
  // vrf = vrf.reversed.toList();

  // return base64.encode(vrf);
}

Future<String> aniwaveDecryptURL(String data) async {
  final vrfKeys = (await MultiApiKeys.fetch()).aniwave!;
  final decryptKey = vrfKeys[1];

  final chiper = RC4(decryptKey);
  final List<int> decrypted = chiper.encodeBytes(base64.decode(data));

  return Uri.decodeComponent(utf8.decode(decrypted));
}
