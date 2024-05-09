import 'dart:async';

import 'package:cloud_hook/utils/url_utils.dart';
import 'package:html/dom.dart' as dom;

abstract class Selector<R> {
  FutureOr<R> select(dom.Element element);
}

class ItemsList<R> extends Selector<List<R>> {
  final String itemScope;
  final Selector<R> child;

  ItemsList({required this.itemScope, required this.child});

  @override
  FutureOr<List<R>> select(dom.Element element) async {
    return Stream.fromIterable(element.querySelectorAll(itemScope))
        .asyncMap((e) => child.select(e))
        .toList();
  }
}

class Scope<R> extends Selector<R> {
  final String scope;
  final Selector<R> child;
  R? defaultValue;

  Scope({required this.scope, required this.child, this.defaultValue});

  @override
  FutureOr<R> select(dom.Element element) {
    final scopedElement = element.querySelector(scope);

    if (scopedElement == null) {
      return Future.value(defaultValue);
    }

    return child.select(scopedElement);
  }
}

class SelectorsMap extends Selector<Map<String, Object?>> {
  final Map<String, Selector<Object?>> children;

  SelectorsMap(this.children);

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
  final Selector<E> child;

  Transform({required this.map, required this.child});

  @override
  FutureOr<T> select(dom.Element element) async {
    return map(await child.select(element));
  }
}

class Text extends Selector<String?> {
  @override
  FutureOr<String?> select(dom.Element element) {
    return element.text;
  }

  static Selector<String?> forScope(String scope) {
    return Scope(scope: scope, child: Text(), defaultValue: "");
  }
}

class TextNodes extends Selector<String?> {
  @override
  FutureOr<String?> select(dom.Element element) {
    return element.nodes
        .where((node) => node.nodeType == dom.Node.TEXT_NODE)
        .map((node) => node.text?.trim())
        .nonNulls
        .join("\n");
  }

  static Selector<String?> forScope(String scope) {
    return Scope(scope: scope, child: TextNodes(), defaultValue: "");
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
    return Scope(scope: scope, child: Attribute(attribute), defaultValue: "");
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

class Join extends Merge<String, Object?> {
  Join(Iterable<Selector<Object?>> children, {separator = " "})
      : super(
          merge: (result) => result.nonNulls.join(separator),
          children: children,
        );
}

class Image extends Transform<String, String?> {
  Image(String host, {attribute = "src"})
      : super(
          map: (url) => url != null ? absoluteUrl(host, url) : "",
          child: Attribute(attribute),
        );

  static Selector<String?> forScope(String scope, String host,
      {attribute = "src"}) {
    return Scope(
      scope: scope,
      child: Image(host, attribute: attribute),
      defaultValue: "",
    );
  }
}

class UrlId extends Transform<String, String?> {
  UrlId({attribute = "href"})
      : super(
          map: (url) => url != null ? extractIdFromUrl(url) : "",
          child: Attribute(attribute),
        );

  static Selector<String?> forScope(String scope, {attribute = "href"}) {
    return Scope(
      scope: scope,
      child: UrlId(attribute: attribute),
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
