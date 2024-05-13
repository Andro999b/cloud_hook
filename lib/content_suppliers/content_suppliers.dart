import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/impl/ua_films_tv.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';

class ContentSuppliers {
  ContentSuppliers._();

  static final ContentSuppliers instance = ContentSuppliers._();

  final List<ContentSupplier> suppliers = List.unmodifiable([
    UAFilmsTVSupplier(),
  ]);

  Set<String> get suppliersName => suppliers.map((i) => i.name).toSet();

  ContentSupplier? getSupplier(String supplierName) {
    return suppliers
        .where((element) => element.name == supplierName)
        .firstOrNull;
  }

  Stream<Map<String, List<ContentSearchResult>>> search(
    String query,
    Set<String> contentSuppliers,
    Set<ContentType> contentTypes,
  ) async* {
    final results = <String, List<ContentSearchResult>>{};
    for (var p in suppliers) {
      if (contentTypes.isNotEmpty &&
          p.supportedTypes.where((e) => contentTypes.contains(e)).isEmpty) {
        continue;
      }

      try {
        final res = await Isolate.run(() => p.search(query, contentTypes));
        results[p.name] = res;
        yield results;
      } catch (error, stackTrace) {
        logger.e("Supplier ${p.name} fail",
            error: error, stackTrace: stackTrace);
      }
    }
  }

  Stream<Map<String, SupplierChannels>> loadRecomendations(
    Map<String, Set<String>> config,
  ) async* {
    final results = <String, SupplierChannels>{};
    for (final MapEntry(key: supplierName, value: channels) in config.entries) {
      final supplier = getSupplier(supplierName);
      if (supplier != null) {
        try {
          results[supplierName] = await Isolate.run(
            () => supplier.loadChannels(channels),
          );
        } catch (error, stackTrace) {
          logger.e(
            "Supplier $supplierName fail to load recomendation channels: $channels",
            error: error,
            stackTrace: stackTrace,
          );
        }
        yield results;
      }
    }
    yield results;
  }

  Future<ContentDetails> detailsById(String supplierName, String id) async {
    logger.i("Load content details supplier: $suppliersName id: $id");

    final supplier = suppliers.where((e) => e.name == supplierName).first;

    try {
      return await Isolate.run(() => supplier.detailsById(id));
    } catch (error, stackTrace) {
      logger.e("Supplier $supplier fail with $id",
          error: error, stackTrace: stackTrace);

      rethrow;
    }
  }
}
