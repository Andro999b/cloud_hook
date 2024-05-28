import 'dart:async';

import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/utils/url_utils.dart';
import 'package:html/dom.dart' as dom;

abstract class Selector<R> {
  FutureOr<R> select(dom.Element element);
}

class IterateOverScope<R> extends Selector<List<R>> {
  final String itemScope;
  final Selector<R> item;

  IterateOverScope({required this.itemScope, required this.item});

  @override
  FutureOr<List<R>> select(dom.Element element) async {
    return Stream.fromIterable(element.querySelectorAll(itemScope))
        .asyncMap((e) => item.select(e))
        .toList();
  }
}

class Scope<R> extends Selector<R> {
  final String scope;
  final Selector<R> item;
  R? defaultValue;

  Scope({required this.scope, required this.item, this.defaultValue});

  @override
  FutureOr<R> select(dom.Element element) {
    final scopedElement = element.querySelector(scope);

    if (scopedElement == null) {
      logger.w("Scope not found: $scope");
      return Future.value(defaultValue);
    }

    return item.select(scopedElement);
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

class Text extends Selector<String> {
  final bool inline;

  Text({this.inline = false});

  @override
  FutureOr<String> select(dom.Element element) {
    final text = element.text.trim();
    if (inline) {
      return text.replaceAll('\n', ' ');
    }
    return text;
  }

  static Selector<String?> forScope(String scope, {inline = false}) {
    return Scope(scope: scope, item: Text(inline: inline), defaultValue: "");
  }
}

class TextNodes extends Selector<String> {
  final bool inline;

  TextNodes({this.inline = false});

  @override
  FutureOr<String> select(dom.Element element) {
    return element.nodes
        .where((node) => node.nodeType == dom.Node.TEXT_NODE)
        .map((node) => node.text?.trim())
        .nonNulls
        .join(inline ? " " : "\n")
        .trim();
  }

  static Selector<String?> forScope(String scope, {inline = false}) {
    return Scope(
        scope: scope, item: TextNodes(inline: inline), defaultValue: "");
  }
}

class Attribute extends Selector<String?> {
  final String attribute;

  Attribute(this.attribute);

  @override
  FutureOr<String?> select(dom.Element element) {
    return element.attributes[attribute];
  }

  static Selector<String?> forScope(String scope, String attribute) {
    return Scope(scope: scope, item: Attribute(attribute), defaultValue: "");
  }
}

typedef MergeFun<R, E> = R Function(List<E>);

class Merge<R, E> extends Selector<R> {
  final MergeFun<R, E> merge;
  final Iterable<Selector<E>> children;

  Merge({required this.merge, required this.children});

  @override
  FutureOr<R> select(dom.Element element) async {
    final result = await Stream.fromIterable(children)
        .asyncMap((child) => child.select(element))
        .toList();

    return merge(result);
  }
}

class ConcatSelectors extends Merge<String, Object?> {
  ConcatSelectors(Iterable<Selector<Object?>> children, {separator = " "})
      : super(
          merge: (result) => result.nonNulls.join(separator),
          children: children,
        );
}

class Join<R> extends Merge<List<R?>, R?> {
  Join(Iterable<Selector<R?>> children)
      : super(
          merge: (result) => result,
          children: children,
        );
}

class Expand<R> extends Merge<List<R?>, List<R?>> {
  Expand(Iterable<Selector<List<R?>>> children, {separator = " "})
      : super(
          merge: (result) => result.expand((e) => e).toList(),
          children: children,
        );
}

class PrependAll<R> extends Selector<List<R?>> {
  final Selector<List<R?>> listSelector;
  final List<Selector<R?>> prependItems;

  PrependAll(this.prependItems, this.listSelector);

  @override
  FutureOr<List<R?>> select(dom.Element element) async {
    final a = await Stream.fromIterable(prependItems)
        .asyncMap((item) => item.select(element))
        .toList();

    final b = await listSelector.select(element);

    return a + b;
  }
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
    return Scope(
      scope: scope,
      item: Image(host, attribute: attribute),
      defaultValue: "",
    );
  }
}

class UrlId extends Transform<String, String?> {
  UrlId({attribute = "href"})
      : super(
          map: (url) => url != null ? extractIdFromUrl(url) : "",
          item: Attribute(attribute),
        );

  static Selector<String?> forScope(String scope, {attribute = "href"}) {
    return Scope(
      scope: scope,
      item: UrlId(attribute: attribute),
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
