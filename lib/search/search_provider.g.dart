// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchHash() => r'b1e6488d184259496a10ffb2194f15b87f5ffbe0';

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
String _$searchSettingsHash() => r'4488db88d6b0f5a84c368a3cb4bedd8bf4d9fdb5';

/// See also [SearchSettings].
@ProviderFor(SearchSettings)
final searchSettingsProvider =
    AutoDisposeNotifierProvider<SearchSettings, SearchSettingsModel>.internal(
  SearchSettings.new,
  name: r'searchSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchSettings = AutoDisposeNotifier<SearchSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
