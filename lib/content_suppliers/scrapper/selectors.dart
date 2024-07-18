import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/utils/url_utils.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

abstract class Selector<R> {
  FutureOr<R> select(dom.Element element);
}

class Iterate<R> extends Selector<List<R>> {
  final String itemScope;
  final Selector<R> item;

  Iterate({required this.itemScope, required this.item});

  @override
  FutureOr<List<R>> select(dom.Element element) async {
    return Stream.fromIterable(element.querySelectorAll(itemScope))
        .asyncMap((e) => item.select(e))
        .toList();
  }
}

class Scope<R> extends Selector<R?> {
  final String scope;
  final Selector<R?> item;

  Scope({required this.scope, required this.item});

  @override
  FutureOr<R?> select(dom.Element element) {
    final scopedElement = element.querySelector(scope);

    if (scopedElement == null) {
      // logger.w("Scope not found: $scope");
      return Future.value(null);
    }

    return item.select(scopedElement);
  }
}

class ScopeWithDefault<R> extends Selector<R> {
  final String scope;
  final Selector<R?> item;
  final R defaultValue;

  ScopeWithDefault({
    required this.scope,
    required this.item,
    required this.defaultValue,
  });

  @override
  Future<R> select(dom.Element element) async {
    final scopedElement = element.querySelector(scope);

    if (scopedElement == null) {
      // logger.w("Scope not found: $scope");
      return Future.value(defaultValue);
    }

    final result = await item.select(scopedElement);

    return result ?? defaultValue;
  }
}

class SelectorsToMap extends Selector<Map<String, Object?>> {
  final Map<String, Selector<Object?>> children;

  SelectorsToMap(this.children);

  @override
  FutureOr<Map<String, Object?>> select(dom.Element element) async {
    final entries = await Stream.fromIterable(children.entries)
        .asyncMap(
          (e) async => MapEntry(
            e.key,
            await e.value.select(element),
          ),
        )
        .toList();

    return Map.fromEntries(entries);
  }
}

typedef TransformFun<T, E> = T Function(E);

class Transform<T, E> extends Selector<T> {
  final TransformFun<T, E> map;
  final Selector<E> item;

  Transform({required this.map, required this.item});

  @override
  FutureOr<T> select(dom.Element element) async {
    return map(await item.select(element));
  }
}

class TextSelector extends Selector<String> {
  static final inlineRegExp = RegExp(r'[\n\t\s]+');
  final bool inline;

  TextSelector({this.inline = false});

  @override
  FutureOr<String> select(dom.Element element) {
    final text = element.text.trim();
    if (inline) {
      return text.replaceAll(inlineRegExp, ' ');
    }
    return text;
  }

  static Selector<String> forScope(String scope, {inline = false}) {
    return ScopeWithDefault(
      scope: scope,
      item: TextSelector(inline: inline),
      defaultValue: "",
    );
  }
}

class TextNode extends Selector<String> {
  final bool inline;

  TextNode({this.inline = false});

  @override
  FutureOr<String> select(dom.Element element) {
    return element.nodes
        .where((node) => node.nodeType == dom.Node.TEXT_NODE)
        .map((node) => node.text?.trim())
        .nonNulls
        .join(inline ? " " : "\n")
        .trim();
  }

  static Selector<String> forScope(String scope, {inline = false}) {
    return ScopeWithDefault(
      scope: scope,
      item: TextNode(inline: inline),
      defaultValue: "",
    );
  }
}

class Attribute extends Selector<String?> {
  final String attribute;

  Attribute(this.attribute);

  @override
  FutureOr<String?> select(dom.Element element) {
    return element.attributes[attribute];
  }

  static Selector<String> forScope(String scope, String attribute) {
    return ScopeWithDefault(
      scope: scope,
      item: Attribute(attribute),
      defaultValue: "",
    );
  }
}

typedef MergeFun<R, E> = R Function(List<E>);

class Merge<R, E> extends Selector<R> {
  final MergeFun<R, E> merge;
  final Iterable<Selector<E?>> children;

  Merge({required this.merge, required this.children});

  @override
  FutureOr<R> select(dom.Element element) async {
    final result = await Stream.fromIterable(children)
        .asyncMap((child) => child.select(element))
        .where((event) => event != null)
        .cast<E>()
        .toList();

    return merge(result);
  }
}

class Join<R> extends Merge<List<R>, R> {
  Join(Iterable<Selector<R?>> children)
      : super(
          merge: (result) => result,
          children: children,
        );
}

class Flatten<R> extends Merge<List<R>, List<R>> {
  Flatten(Iterable<Selector<List<R>>> children)
      : super(
          merge: (result) => result.expand((e) => e).toList(),
          children: children,
        );
}

class Concat extends Selector<String> {
  final Selector<List<String?>> selector;
  final String separator;

  Concat(this.selector, {this.separator = ""});

  @override
  FutureOr<String> select(dom.Element element) async {
    final res = await selector.select(element);

    return res.nonNulls.where((e) => e.isNotEmpty).join(separator);
  }

  factory Concat.selectors(
    Iterable<Selector<String?>> selectors, {
    String separator = "",
  }) =>
      Concat(Join(selectors), separator: separator);
}

class Any extends Selector<String?> {
  final Selector<List<String?>> selector;

  Any(this.selector);

  @override
  FutureOr<String?> select(dom.Element element) async {
    final result = await selector.select(element);

    return result.where((element) => element?.isNotEmpty == true).firstOrNull;
  }

  factory Any.selectors(Iterable<Selector<String?>> selectors) =>
      Any(Join(selectors));
}

class Filter<R> extends Selector<List<R>> {
  final Selector<List<R>> selector;
  final bool Function(R) filter;

  Filter(this.selector, {required this.filter});

  @override
  FutureOr<List<R>> select(dom.Element element) async {
    final res = await selector.select(element);

    return res.where(filter).toList();
  }
}

class Image extends Transform<String, String?> {
  Image(String host, {attribute = "src"})
      : super(
          map: (url) => url != null ? absoluteUrl(host, url) : "",
          item: Attribute(attribute),
        );

  static Selector<String?> forScope(String scope, String host,
      {attribute = "src"}) {
    return ScopeWithDefault(
      scope: scope,
      item: Image(host, attribute: attribute),
      defaultValue: "",
    );
  }
}

class UrlId extends Transform<String, String?> {
  UrlId({attribute = "href", RegExp? regexp})
      : super(
          map: (url) =>
              url != null ? extractIdFromUrl(url, regexp: regexp) : "",
          item: Attribute(attribute),
        );

  static Selector<String?> forScope(
    String scope, {
    attribute = "href",
    RegExp? regexp,
  }) {
    return ScopeWithDefault(
      scope: scope,
      item: UrlId(attribute: attribute, regexp: regexp),
      defaultValue: "",
    );
  }
}

class Const extends Selector<Object> {
  final Object value;

  Const(this.value);

  @override
  FutureOr<Object> select(dom.Element element) {
    return value;
  }
}
