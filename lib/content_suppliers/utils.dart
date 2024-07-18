import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
));
// ..interceptors.add(LogInterceptor(responseBody: false));

// todo: add sentry integration

Uri parseUri(String url) =>
    url.startsWith("//") ? Uri.parse("https:$url") : Uri.parse(url);

// 195.230.23.7,
// 195.230.23.67,
// 195.230.23.77,
// 195.230.23.79,
// 195.230.23.83,
// 195.230.23.63,
// 91.206.228.57
const cloudWallIp = "195.230.23.67";
