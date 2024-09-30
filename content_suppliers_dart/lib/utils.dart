import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

// todo: add sentry integration
final dio = Dio()
  // ..interceptors.add(LogInterceptor(responseBody: false))
  ..options.sendTimeout = const Duration(seconds: 30)
  ..options.receiveTimeout = const Duration(seconds: 30);

final logger = Logger();

int extractDigits(String text) {
  int acc = 0;
  bool found = false;

  for (final ch in text.characters) {
    final num = int.tryParse(ch);
    if (num != null) {
      found = true;
      acc = acc * 10 + num;
    } else if (found) {
      break;
    }
  }

  return acc;
}

String absoluteUrl(String host, String url) {
  final uri = Uri.parse(url);

  return uri.replace(host: host, scheme: "https").toString();
}

Uri parseUri(String url) =>
    url.startsWith("//") ? Uri.parse("https:$url") : Uri.parse(url);

final defaultIdRegexp = RegExp(r'https?:\/\/[\w\.\-\d]+\/(?<id>.+).html?');

String extractIdFromUrl(String url, {RegExp? regexp}) {
  final match = (regexp ?? defaultIdRegexp).firstMatch(url);
  final id = match?.namedGroup("id");

  if (id == null) {
    throw Exception("id not found in url: $url");
  }

  return id;
}
