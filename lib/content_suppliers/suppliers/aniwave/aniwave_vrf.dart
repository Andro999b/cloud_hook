import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';

// load separetelly

Future<String> aniwaveEncryptVRF(String data) async {
  final vrfOps = (await MultiApiKeys.fetch()).aniwave!;
  String out = data;

  for (var op in vrfOps) {
    out = op.encrypt(out);
  }

  return out;
}

Future<String> aniwaveDecryptURL(String data) async {
  final vrfOps = (await MultiApiKeys.fetch()).aniwave!;
  String out = data;

  for (var op in vrfOps.reversed) {
    out = op.decrypt(out);
  }

  return Uri.decodeComponent(out);
}
