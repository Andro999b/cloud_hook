import 'dart:async';

import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

const defaultHeaders = {
  "User-Agent":
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
};

class Scrapper {
  final String uri;
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
      uri,
      options: Options(
        method: method,
        headers: {...defaultHeaders, ...headers},
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
      data: form != null
          ? FormData.fromMap(form!, ListFormat.multiCompatible)
          : body,
    );

    return resposnse.data;
  }

  static FutureOr<R?> scrapFragment<R>(
      String text, String root, Selector<R> selector) async {
    final rootElement = parser.parseFragment(text).querySelector(root);

    if (rootElement == null) {
      logger.w("Root element $root not found");
      return null;
    }

    return selector.select(rootElement);
  }
}