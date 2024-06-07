import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';

ContentItemMediaSourceLoader aggSourceLoader(
  List<ContentItemMediaSourceLoader> sourceLoaders,
) =>
    () => Isolate.run(() => Stream.fromIterable(sourceLoaders)
        .asyncMap((loader) async {
          try {
            return await loader();
          } catch (error, stackTrace) {
            logger.w("Source loader error: $error", stackTrace: stackTrace);
            return <ContentMediaItemSource>[];
          }
        })
        .expand((s) => s)
        .toList());
