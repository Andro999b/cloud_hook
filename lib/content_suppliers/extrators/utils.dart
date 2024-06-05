import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/model.dart';

ContentItemMediaSourceLoader aggSourceLoader(
  List<ContentItemMediaSourceLoader> sourceLoaders,
) =>
    () => Isolate.run(() => Stream.fromIterable(sourceLoaders)
        .asyncMap((loader) => loader())
        .expand((s) => s)
        .toList());
