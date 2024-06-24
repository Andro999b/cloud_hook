import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
));
// ..interceptors.add(LogInterceptor(
//   requestBody: true,
//   responseBody: false,
//   // logPrint: logger.i,
// ));

// todo: add sentry integration

Uri parseUri(String url) =>
    url.startsWith("//") ? Uri.parse("https:$url") : Uri.parse(url);
