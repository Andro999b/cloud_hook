import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/impl/animeua/animeua.dart';
import 'package:cloud_hook/content_suppliers/impl/eneyida/eneyida.dart';
import 'package:cloud_hook/content_suppliers/impl/uafilms/uafilms.dart';
import 'package:cloud_hook/content_suppliers/impl/uakinoclub/uakinoclub.dart';
import 'package:cloud_hook/content_suppliers/impl/ufdub/ufdub.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/logger.dart';

class ContentSuppliers {
  ContentSuppliers._();

  static final ContentSuppliers instance = ContentSuppliers._();

  final List<ContentSupplier> suppliers = List.unmodifiable([
    UAKinoClubSupplier(),
    EneyidaSupplier(),
    AnimeUASupplier(),
    UAFilmsSupplier(),
    UFDubSupplier(),
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
    for (var s in suppliers) {
      if (!contentSuppliers.contains(s.name) ||
          s.supportedTypes.intersection(contentTypes).isEmpty) {
        continue;
      }

      try {
        final res = await Isolate.run(() => s.search(query, contentTypes));
        results[s.name] = res;
        yield results;
      } catch (error, stackTrace) {
        logger.e("Supplier ${s.name} fail",
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
