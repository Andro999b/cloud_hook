import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suppliers_settings_provider.g.dart';

@immutable
class SuppliersConfig extends Equatable {
  final bool enabled;
  final Set<String> channels;

  const SuppliersConfig({
    this.enabled = false,
    this.channels = const {},
  });

  SuppliersConfig copyWith({
    bool? enabled,
    Set<String>? channels,
  }) {
    return SuppliersConfig(
      enabled: enabled ?? this.enabled,
      channels: channels ?? this.channels,
    );
  }

  @override
  List<Object?> get props => [enabled, channels];
}

@immutable
class SuppliersSettingsModel extends Equatable {
  final List<String> suppliersOrder;
  final Map<String, SuppliersConfig> configs;

  const SuppliersSettingsModel({
    required this.suppliersOrder,
    required this.configs,
  });

  SuppliersSettingsModel copyWith(
      {List<String>? suppliersOrder, Map<String, SuppliersConfig>? configs}) {
    return SuppliersSettingsModel(
      suppliersOrder: suppliersOrder ?? this.suppliersOrder,
      configs: configs != null ? {...this.configs, ...configs} : this.configs,
    );
  }

  SuppliersConfig getConfig(String supplier) {
    return configs[supplier] ?? const SuppliersConfig();
  }

  @override
  List<Object?> get props => [suppliersOrder, configs];
}

@Riverpod(keepAlive: true)
class SuppliersSettings extends _$SuppliersSettings {
  @override
  SuppliersSettingsModel build() {
    final contentSuppliers = ContentSuppliers.instance;
    final supplierNames = contentSuppliers.suppliersName;

    Set<String> suppliersOrder;
    final savedOrder = AppPreferences.suppliersOrder;

    if (savedOrder != null) {
      suppliersOrder = Set.from(savedOrder);
      suppliersOrder.removeWhere((e) => !supplierNames.contains(e));
      suppliersOrder.addAll(supplierNames);
    } else {
      suppliersOrder = supplierNames;
    }

    return SuppliersSettingsModel(
      suppliersOrder: suppliersOrder.toList(),
      configs: {
        for (final supplierName in suppliersOrder)
          supplierName: SuppliersConfig(
            enabled: AppPreferences.getSupplierEnabled(supplierName) ?? true,
            channels: AppPreferences.getSupplierChannels(supplierName) ??
                contentSuppliers.getSupplier(supplierName)?.defaultChannels ??
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

    AppPreferences.suppliersOrder = suppliersOrder;
    state = state.copyWith(suppliersOrder: suppliersOrder);
  }

  void enableSupplier(String supplierName) {
    final config = state.getConfig(supplierName);

    AppPreferences.setSupplierEnabled(supplierName, true);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(enabled: true),
    });
  }

  void disableSupplier(String supplierName) {
    final config = state.getConfig(supplierName);

    AppPreferences.setSupplierEnabled(supplierName, false);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(enabled: false),
    });
  }

  void enableChannel(String supplierName, String channel) {
    final config = state.getConfig(supplierName);

    final newChannels = {...config.channels, channel};

    AppPreferences.setSupplierChannels(supplierName, newChannels);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(channels: newChannels),
    });
  }

  void disableChannel(String supplierName, String channel) {
    final config = state.getConfig(supplierName);

    final newChannels =
        config.channels.where((element) => element != channel).toSet();

    AppPreferences.setSupplierChannels(supplierName, newChannels);
    state = state.copyWith(configs: {
      supplierName: config.copyWith(channels: newChannels),
    });
  }
}

@Riverpod(keepAlive: true)
Set<String> enabledSuppliers(EnabledSuppliersRef ref) {
  final suppliersSettings = ref.watch(suppliersSettingsProvider);
  return suppliersSettings.suppliersOrder
      .where((element) => suppliersSettings.getConfig(element).enabled)
      .toSet();
}
