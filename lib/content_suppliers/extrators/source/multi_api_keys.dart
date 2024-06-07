import 'dart:convert';

import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
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

  MultiApiKeys._();

  static Future<ApiKeys> fetch() async {
    final res = await dio.get(url);

    return ApiKeys.fromJson(json.decode(res.data));
  }
}
