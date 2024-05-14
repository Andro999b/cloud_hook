import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recomendations_settings_provider.g.dart';

@immutable
class RecomendationConfig extends Equatable {
  final bool enabled;
  final Set<String> channels;

  const RecomendationConfig({
    this.enabled = false,
    this.channels = const {},
  });

  RecomendationConfig copyWith({
    bool? enabled,
    Set<String>? channels,
  }) {
    return RecomendationConfig(
      enabled: enabled ?? this.enabled,
      channels: channels ?? this.channels,
    );
  }

  @override
  List<Object?> get props => [enabled, channels];
}

@immutable
class RecomendationsModel extends Equatable {
  final List<String> suppliersOrder;
  final Map<String, RecomendationConfig> configs;

  const RecomendationsModel({
    required this.suppliersOrder,
    required this.configs,
  });

  RecomendationsModel copyWith(
      {List<String>? suppliersOrder,
      Map<String, RecomendationConfig>? configs}) {
    return RecomendationsModel(
      suppliersOrder: suppliersOrder ?? this.suppliersOrder,
      configs: configs != null ? {...this.configs, ...configs} : this.configs,
    );
  }

  RecomendationConfig getConfig(String supplier) {
    return configs[supplier] ?? const RecomendationConfig();
  }

  @override
  List<Object?> get props => [suppliersOrder, configs];
}

@Riverpod(keepAlive: true)
class RecomendationSettings extends _$RecomendationSettings {
  @override
  RecomendationsModel build() {
    final defaultSuppliers = ContentSuppliers.instance.suppliers
        .where((s) => s.defaultChannels.isNotEmpty);

    final defaultSuppliersByName = {
      for (final supplier in defaultSuppliers) supplier.name: supplier
    };

    final supplierNames = ContentSuppliers.instance.suppliersName;

    Set<String> suppliersOrder;
    final savedOrder = AppPreferences.recomendationsOrder;

    if (savedOrder != null) {
      suppliersOrder = Set.from(savedOrder);
      suppliersOrder.removeWhere((e) => !supplierNames.contains(e));
      suppliersOrder.addAll(supplierNames);
    } else {
      suppliersOrder = defaultSuppliers.map((e) => e.name).toSet();
    }

    return RecomendationsModel(
      suppliersOrder: suppliersOrder.toList(),
      configs: {
        for (final supplierName in suppliersOrder)
          supplierName: RecomendationConfig(
            enabled:
                AppPreferences.getRecomendationSupplierEnabled(supplierName) ??
                    defaultSuppliersByName.keys.contains(supplierName),
            channels:
                AppPreferences.getRecomendationSupplierChannels(supplierName) ??
                    defaultSuppliersByName[supplierName]?.defaultChannels ??
                    const {},
          )
      },
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final suppliersOrder = [...state.suppliersOrder];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = suppliersOrder.removeAt(oldIndex);
    suppliersOrder.insert(newIndex, item);

    AppPreferences.recomendationsOrder = suppliersOrder;
    state = state.copyWith(suppliersOrder: suppliersOrder);
  }

  void enableSupplier(String supplierName) {
    final config = state.getConfig(supplierName);

    AppPreferences.setRecomendationSupplierEnabled(supplierName, true);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(enabled: true),
    });
  }

  void disableSupplier(String supplierName) {
    final config = state.getConfig(supplierName);

    AppPreferences.setRecomendationSupplierEnabled(supplierName, false);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(enabled: false),
    });
  }

  void enableChannel(String supplierName, String channel) {
    final config = state.getConfig(supplierName);

    final newChannels = {...config.channels, channel};

    AppPreferences.setRecomendationSupplierChannels(supplierName, newChannels);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(channels: newChannels),
    });
  }

  void disableChannel(String supplierName, String channel) {
    final config = state.getConfig(supplierName);

    final newChannels =
        config.channels.where((element) => element != channel).toSet();

    AppPreferences.setRecomendationSupplierChannels(supplierName, newChannels);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(channels: newChannels),
    });
  }
}
