import 'dart:async';

import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

const desktopUserAgent =
    "Mozilla/5.0 (X11; Linux x86_64; rv:127.0) Gecko/20100101 Firefox/127.0";
const mobileUserAgent =
    "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1";

const defaultHeaders = {
  "User-Agent": desktopUserAgent,
};

typedef RootElementSelector = dom.Element Function(dom.Document document);

class Scrapper {
  final Uri uri;
  final String method;
  final Map<String, String?> headers;
  final Object? body;
  final Map<String, Object>? form;
  // final String? encoding;

  dom.Document? _document;
  String? _page;

  String get pageContent => _page ?? "";

  Scrapper({
    required this.uri,
    this.method = "get",
    this.headers = const {},
    this.body,
    this.form,
    // this.encoding,
  });

  FutureOr<R?> scrap<R>(
    Selector<R> selector, {
    RootElementSelector? rootElementSelector,
  }) async {
    if (_document == null) {
      _page = await _loadPage();

      if (_page == null) {
        return null;
      }

      _document = parser.parse(_page);
    }

    return selector.select(
      rootElementSelector != null
          ? rootElementSelector.call(_document!)
          : _document!.body!,
    );
  }

  Future<String?> _loadPage() async {
    final resposnse = await dio.requestUri(
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
