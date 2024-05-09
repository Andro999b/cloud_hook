import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';

const defaultHeaders = {
  "User-Agent":
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
};

class Scrapper {
  final Uri uri;
  final String method;
  final Map<String, String> headers;
  final Map<String, String>? body;
  final String? encoding;

  dom.Document? _document;

  Scrapper({
    required this.uri,
    this.method = "get",
    this.headers = const {},
    this.body,
    this.encoding,
  });

  FutureOr<R> scrap<R>(Selector<R> selector) async {
    if (_document == null) {
      final page = await _loadPage();
      _document = parser.parse(page);
    }

    return selector.select(_document!.body!);
  }

  Future<String> _loadPage() async {
    final request = http.Request(method, uri)
      ..headers.addAll(defaultHeaders)
      ..headers.addAll(headers);

    if (body != null) request.bodyFields = body!;
    if (encoding != null) request.encoding = Encoding.getByName(encoding)!;

    final response = await Response.fromStream(await request.send());

    return response.body;
  }
}
