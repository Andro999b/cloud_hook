import 'dart:isolate';
import 'dart:typed_data';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';

ContentItemMediaSourceLoader aggSourceLoader(
  Iterable<ContentItemMediaSourceLoader> sourceLoaders,
) =>
    () => Stream.fromIterable(sourceLoaders)
        .asyncMap((loader) async {
          try {
            return await Isolate.run(loader);
          } catch (error, stackTrace) {
            logger.w("Source loader error: $error", stackTrace: stackTrace);
            return <ContentMediaItemSource>[];
          }
        })
        .expand((s) => s)
        .toList();

Uint8List hexToBytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}
