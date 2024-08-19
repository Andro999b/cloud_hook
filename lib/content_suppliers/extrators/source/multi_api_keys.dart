import 'dart:convert';

import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:simple_rc4/simple_rc4.dart';

part 'multi_api_keys.g.dart';

@JsonSerializable(createToJson: false)
class ApiKeys {
  final List<String>? chillx;
  final List<KeyOps>? vidplay;
  final List<KeyOps>? aniwave;
  final List<KeyOps>? cinezone;

  ApiKeys({this.chillx, this.vidplay, this.aniwave, this.cinezone});

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
  static const url = "https://rowdy-avocado.github.io/multi-keys/";

  static const refreshInterval = Duration(seconds: 3600);
  static DateTime? _lastRefresh;
  static ApiKeys? _lastKeys;

  MultiApiKeys._();

  static Future<ApiKeys> fetch() async {
    if (_lastRefresh == null ||
        DateTime.now().difference(_lastRefresh!) > refreshInterval) {
      final res = await dio.get(url);
      _lastKeys = ApiKeys.fromJson(json.decode(res.data));
      _lastRefresh = DateTime.now();
    }

    return _lastKeys!;
  }
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
