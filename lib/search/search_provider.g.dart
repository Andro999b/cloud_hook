// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchHash() => r'2421ff6fbbd7417898fec6afb6ff6e1cc46db712';

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
String _$selectedSupplierHash() => r'c438e064a05dfc9b81a283f35bf24d5bd3726490';

/// See also [SelectedSupplier].
@ProviderFor(SelectedSupplier)
final selectedSupplierProvider =
    AutoDisposeNotifierProvider<SelectedSupplier, Set<String>>.internal(
  SelectedSupplier.new,
  name: r'selectedSupplierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSupplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSupplier = AutoDisposeNotifier<Set<String>>;
String _$selectedContentHash() => r'9f4fbdef92497e4fbe33c80fcdaa30d1fb10ac10';

/// See also [SelectedContent].
@ProviderFor(SelectedContent)
final selectedContentProvider =
    AutoDisposeNotifierProvider<SelectedContent, Set<ContentType>>.internal(
  SelectedContent.new,
  name: r'selectedContentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedContentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedContent = AutoDisposeNotifier<Set<ContentType>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
