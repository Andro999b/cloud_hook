import 'package:dio/dio.dart';

// todo: add sentry integration
final dio = Dio()
  // ..interceptors.add(LogInterceptor(responseBody: false))
  ..options.sendTimeout = const Duration(seconds: 30)
  ..options.receiveTimeout = const Duration(seconds: 30);

Uri parseUri(String url) =>
    url.startsWith("//") ? Uri.parse("https:$url") : Uri.parse(url);
