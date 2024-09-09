import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';

class AggSourceLoader implements ContentMediaItemSourceLoader {
  final List<ContentMediaItemSourceLoader> sourceLoaders;

  AggSourceLoader(this.sourceLoaders);

  @override
  Future<List<ContentMediaItemSource>> call() {
    return Stream.fromIterable(sourceLoaders)
        .asyncMap(
          (loader) => Isolate.run(() async {
            try {
              return await loader.call();
            } catch (error, stackTrace) {
              logger.w("Source loader $loader error: $error",
                  stackTrace: stackTrace);
              return <ContentMediaItemSource>[];
            }
          }),
        )
        .expand((s) => s)
        .toList();
  }
}

Uint8List hexToBytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}

typedef CachedKeyParseFun<K> = K Function(String data);

class CachedKey<K> {
  Duration refreshInterval;
  final String url;
  final CachedKeyParseFun<K> parse;

  DateTime? _lastRefresh;
  K? _lastValue;

  CachedKey({
    required this.url,
    required this.parse,
    this.refreshInterval = const Duration(seconds: 3600),
  });

  Future<K> fetch() async {
    if (_lastRefresh == null ||
        DateTime.now().difference(_lastRefresh!) > refreshInterval) {
      final res = await dio.get(url);
      _lastValue = parse(res.data);
      _lastRefresh = DateTime.now();
    }

    return _lastValue!;
  }
}
