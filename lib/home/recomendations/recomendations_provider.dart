import 'dart:async';

import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/recomendations/recomendations_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recomendations_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<Map<String, SupplierChannels>> recomendations(Ref ref) {
  final settings = ref.watch(recomendationSettingsProvider);

  final entries = settings.suppliersOrder
      .where((e) => settings.configs[e]?.enabled ?? false)
      .map(
        (supplierName) => MapEntry(
          supplierName,
          settings.configs[supplierName]?.channels ?? const {},
        ),
      )
      .where((e) => e.value.isNotEmpty);

  return ContentSuppliers.instance.loadRecomendations(
    Map.fromEntries(entries),
  );
}
