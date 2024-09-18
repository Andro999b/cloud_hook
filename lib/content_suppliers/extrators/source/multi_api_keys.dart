import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:simple_rc4/simple_rc4.dart';

part 'multi_api_keys.g.dart';

@JsonSerializable(createToJson: false)
class ApiKeys {
  final List<String>? chillx;

  ApiKeys({
    this.chillx,
  });

  factory ApiKeys.fromJson(Map<String, dynamic> json) =>
      _$ApiKeysFromJson(json);
}

@JsonSerializable(createToJson: false)
class KeyOps {
  final int sequence;
  final String method;
  final List<String>? keys;

  KeyOps({
    required this.sequence,
    required this.method,
    required this.keys,
  });

  factory KeyOps.fromJson(Map<String, dynamic> json) => _$KeyOpsFromJson(json);

  String encrypt(String input) {
    return switch (method) {
      "exchange" => runExchangeOp(input, keys?[0] ?? "", keys?[1] ?? ""),
      "rc4" => runRC4EncryptOp(input, keys?[0] ?? ""),
      "reverse" => runReverseOp(input),
      "base64" => base64Url.encode(utf8.encode(input)),
      _ => input
    };
  }

  String decrypt(String input) {
    return switch (method) {
      "exchange" => runExchangeOp(input, keys?[1] ?? "", keys?[0] ?? ""),
      "rc4" => runRC4DecryptOp(input, keys?[0] ?? ""),
      "reverse" => runReverseOp(input),
      "base64" => utf8.decode(base64Url.decode(input)),
      _ => input
    };
  }
}

class MultiApiKeys {
  static CachedKey<ApiKeys> keys = CachedKey(
    url: "https://rowdy-avocado.github.io/multi-keys/",
    parse: (data) => ApiKeys.fromJson(json.decode(data)),
  );

  MultiApiKeys._();
}

String runExchangeOp(String input, String k1, String k2) {
  return input.characters.map((c) {
    final index = k1.indexOf(c);
    if (index != -1) {
      return k2[index];
    } else {
      return c;
    }
  }).join();
}

String runReverseOp(String input) {
  return input.characters.toList().reversed.join();
}

String runRC4EncryptOp(String input, String key) {
  final chiper = RC4(key);

  List<int> vrf = chiper.encodeBytes(utf8.encode(input));
  return base64Url.encode(vrf);
}

String runRC4DecryptOp(String input, String key) {
  final chiper = RC4(key);

  final List<int> decrypted = chiper.encodeBytes(base64.decode(input));
  return utf8.decode(decrypted);
}
