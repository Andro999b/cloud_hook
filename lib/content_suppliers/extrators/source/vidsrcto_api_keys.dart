import 'dart:convert';

import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vidsrcto_api_keys.g.dart';

@JsonSerializable(createToJson: false)
class ApiKeys {
  final List<String> encrypt;
  final List<String> decrypt;

  ApiKeys({required this.encrypt, required this.decrypt});

  factory ApiKeys.fromJson(Map<String, dynamic> json) => _$ApiKeysFromJson(json);
}

class VidsrcToApiKeys {
  static const url = "https://raw.githubusercontent.com/Ciarands/vidsrc-keys/main/keys.json";

  static const refreshInterval = Duration(seconds: 3600);
  static DateTime? _lastRefresh;
  static ApiKeys? _lastKeys;

  VidsrcToApiKeys._();

  static Future<ApiKeys> fetch() async {
    if (_lastRefresh == null || DateTime.now().difference(_lastRefresh!) > refreshInterval) {
      final res = await dio.get(url);
      _lastKeys = ApiKeys.fromJson(json.decode(res.data));
      _lastRefresh = DateTime.now();
    }

    return _lastKeys!;
  }
}
