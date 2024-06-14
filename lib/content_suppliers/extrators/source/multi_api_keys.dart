import 'dart:convert';

import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'multi_api_keys.g.dart';

@JsonSerializable(createToJson: false)
class ApiKeys {
  final List<String>? chillx;
  final List<String>? vidplay;
  final List<String>? aniwave;
  final List<String>? cinezone;

  ApiKeys({this.chillx, this.vidplay, this.aniwave, this.cinezone});

  factory ApiKeys.fromJson(Map<String, dynamic> json) =>
      _$ApiKeysFromJson(json);
}

class MultiApiKeys {
  static const url =
      "https://raw.githubusercontent.com/rushi-chavan/multi-keys/keys/keys.json";

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
