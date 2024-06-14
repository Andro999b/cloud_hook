import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/digests/md5.dart';

(Uint8List, Uint8List) deriveKeyAndIV(
  Uint8List passphrase,
  Uint8List salt,
) {
  const int keyLength = 32;
  const int ivLength = 16;
  const int targetSize = ivLength + keyLength;
  final md5 = MD5Digest();
  final result = Uint8List(targetSize);

  var resultSize = 0;

  while (resultSize < targetSize) {
    if (resultSize > 0) {
      md5.update(result, resultSize - md5.digestSize, md5.digestSize);
    }

    md5.update(passphrase, 0, passphrase.length);
    md5.update(salt, 0, salt.length);
    md5.doFinal(result, resultSize);
    resultSize += md5.digestSize;
  }

  return (
    result.sublist(0, keyLength),
    result.sublist(keyLength, targetSize),
  );
}
