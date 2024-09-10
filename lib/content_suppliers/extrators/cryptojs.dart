import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/digests/md5.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String cryptoJSDecrypt64(Uint8List password, Uint8List salt, String encrypted) {
  final (key, iv) = deriveKeyAndIV(password, salt);

  final encrypter = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(key),
    mode: encrypt.AESMode.cbc,
    padding: "PKCS7",
  ));

  return encrypter.decrypt64(encrypted, iv: encrypt.IV(iv));
}

String cryptoJSDecrypt(
    Uint8List password, Uint8List salt, Uint8List encrypted) {
  final (key, iv) = deriveKeyAndIV(password, salt);

  final encrypter = encrypt.Encrypter(encrypt.AES(
    encrypt.Key(key),
    mode: encrypt.AESMode.cbc,
    padding: "PKCS7",
  ));

  return encrypter.decrypt(encrypt.Encrypted(encrypted), iv: encrypt.IV(iv));
}

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
