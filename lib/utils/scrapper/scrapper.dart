import 'dart:async';

import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

const defaultHeaders = {
  "User-Agent":
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
};

final dio = Dio()
  ..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: false,
    // logPrint: logger.i,
  ));

class Scrapper {
  final Uri uri;
  final String method;
  final Map<String, String> headers;
  final Object? body;
  final Map<String, Object>? form;
  // final String? encoding;

  dom.Document? _document;

  Scrapper({
    required this.uri,
    this.method = "get",
    this.headers = const {},
    this.body,
    this.form,
    // this.encoding,
  });

  FutureOr<R> scrap<R>(Selector<R> selector) async {
    if (_document == null) {
      final page = await _loadPage();
      _document = parser.parse(page);
    }

    return selector.select(_document!.body!);
  }

  Future<String> _loadPage() async {
    final resposnse = await dio.request(
      uri.toString(),
      options: Options(
        method: method,
        headers: {...defaultHeaders, ...headers},
      ),
      data: form != null
          ? FormData.fromMap(form!, ListFormat.multiCompatible)
          : body,
    );

    return resposnse.data;
  }
}
