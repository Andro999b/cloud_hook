// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enabledSuppliersHash() => r'b41cb6e694864160af24b2c9a9be830ea5d5df71';

/// See also [enabledSuppliers].
@ProviderFor(enabledSuppliers)
final enabledSuppliersProvider = Provider<Set<String>>.internal(
  enabledSuppliers,
  name: r'enabledSuppliersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enabledSuppliersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EnabledSuppliersRef = ProviderRef<Set<String>>;
String _$suppliersSettingsHash() => r'da163b5adc9f4549f370f9510f08e5a5b49bd60d';

/// See also [SuppliersSettings].
@ProviderFor(SuppliersSettings)
final suppliersSettingsProvider =
    NotifierProvider<SuppliersSettings, SuppliersSettingsModel>.internal(
  SuppliersSettings.new,
  name: r'suppliersSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suppliersSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SuppliersSettings = Notifier<SuppliersSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
