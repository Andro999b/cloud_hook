import 'dart:isolate';

import 'package:cloud_hook/app_secrets.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/bundle.dart';

class ContentSuppliers {
  ContentSuppliers._();

  static final ContentSuppliers instance = ContentSuppliers._();

  final List<ContentSupplierBundle> _bundles = [
    DartContentSupplierBundle(tmdbSecret: AppSecrets.getString("tmdb"))
  ];

  Future<void> load() async {
    List<ContentSupplier> suppliers = [];
    for (final bundle in _bundles) {
      suppliers += await bundle.suppliers;
    }
    _suppliers = suppliers;
    _suppliersByName = {for (var s in suppliers) s.name: s};
  }

  List<ContentSupplier> _suppliers = [];
  Map<String, ContentSupplier> _suppliersByName = {};

  Set<String> get suppliersName => _suppliersByName.keys.toSet();

  ContentSupplier? getSupplier(String supplierName) {
    return _suppliersByName[supplierName];
  }

  Stream<Map<String, List<ContentInfo>>> search(
    String query,
    Set<String> contentSuppliers,
    Set<ContentType> contentTypes,
  ) async* {
    final results = <String, List<ContentInfo>>{};
    for (var supplierName in contentSuppliers) {
      final supplier = getSupplier(supplierName);

      if (supplier == null ||
          supplier.supportedTypes.intersection(contentTypes).isEmpty) {
        continue;
      }

      try {
        final res = await Isolate.run(
          () => supplier.search(query, contentTypes),
        );
        results[supplier.name] = res;
        yield results;
      } catch (error, stackTrace) {
        logger.e("Supplier ${supplier.name} fail",
            error: error, stackTrace: stackTrace);
      }
    }

    yield results;
  }

  Future<List<ContentInfo>> loadRecomendationsChannel(
      String supplierName, String channel,
      {page = 1}) async {
    logger.i(
        "Loading content supplier: $supplierName recommendations channel: $channel");

    final supplier = getSupplier(supplierName);

    if (supplier == null) {
      return [];
    }

    return Isolate.run(() => supplier.loadChannel(channel, page: page));
  }

  Future<ContentDetails> detailsById(String supplierName, String id) async {
    logger.i("Load content details supplier: $supplierName id: $id");

    final supplier =
        _suppliers.where((e) => e.name == supplierName).firstOrNull;

    if (supplier == null) {
      throw Exception("No supplier $supplierName found");
    }

    ContentDetails? details;
    try {
      details = await Isolate.run(() => supplier.detailsById(id));
    } catch (error, stackTrace) {
      logger.e("Supplier $supplier fail with $id",
          error: error, stackTrace: stackTrace);

      rethrow;
    }

    if (details == null) {
      throw Exception("Details not found by supplier: $supplier and id: $id");
    }

    return details;
  }
}
