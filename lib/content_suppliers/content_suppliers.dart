import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/impl/ua_films_tv.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';

class ContentSuppliers {
  ContentSuppliers._();

  static final ContentSuppliers instance = ContentSuppliers._();

  final List<ContentSupplier> _suppliers = [UAFilmsTVSupplier()];

  Set<String> get suppliersName => _suppliers.map((i) => i.name).toSet();

  Stream<MapEntry<String, Iterable<ContentSearchResult>>> search(String query,
      Set<String> contentSuppliers, Set<ContentType> contentTypes) async* {
    for (var p in _suppliers) {
      if (p.supportedTypes.where((e) => contentTypes.contains(e)).isNotEmpty) {
        continue;
      }

      try {
        final res = await Isolate.run(() => p.search(query, contentTypes));
        yield MapEntry(p.name, res);
      } catch (error, stackTrace) {
        logger.e("Supplier ${p.name} fail",
            error: error, stackTrace: stackTrace);
      }
    }
  }

  Future<ContentDetails> detailsById(String supplierName, String id) async {
    logger.i("Load content details supplier: $suppliersName id: $id");

    final supplier = _suppliers.where((e) => e.name == supplierName).first;

    try {
      return await Isolate.run(() => supplier.detailsById(id));
    } catch (error, stackTrace) {
      logger.e("Supplier $supplier fail with $id",
          error: error, stackTrace: stackTrace);

      rethrow;
    }
  }
}
