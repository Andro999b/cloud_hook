// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchHash() => r'0e98517654ab14c85d32eaf948333062d830f6ae';

/// See also [Search].
@ProviderFor(Search)
final searchProvider = NotifierProvider<Search, SearchState>.internal(
  Search.new,
  name: r'searchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Search = Notifier<SearchState>;
String _$selectedSupplierHash() => r'189550672ce93fd86c86031b6f2b49e6a50ebb89';

/// See also [SelectedSupplier].
@ProviderFor(SelectedSupplier)
final selectedSupplierProvider =
    NotifierProvider<SelectedSupplier, Set<String>>.internal(
  SelectedSupplier.new,
  name: r'selectedSupplierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSupplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSupplier = Notifier<Set<String>>;
String _$selectedContentHash() => r'f9e4fac1d7a920bc6824606019e632ef7c4b9fb8';

/// See also [SelectedContent].
@ProviderFor(SelectedContent)
final selectedContentProvider =
    NotifierProvider<SelectedContent, Set<ContentType>>.internal(
  SelectedContent.new,
  name: r'selectedContentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedContent = Notifier<Set<ContentType>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
