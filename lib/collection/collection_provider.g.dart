// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionServiceHash() => r'903f958ae1c771553d27ee159089b670a27e5d67';

/// See also [collectionService].
@ProviderFor(collectionService)
final collectionServiceProvider = Provider<CollectionService>.internal(
  collectionService,
  name: r'collectionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CollectionServiceRef = ProviderRef<CollectionService>;
String _$collectionHash() => r'38b550ea11947f30d00dbf40fbebd5c21faf7222';

/// See also [collection].
@ProviderFor(collection)
final collectionProvider = AutoDisposeFutureProvider<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>.internal(
  collection,
  name: r'collectionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$collectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CollectionRef = AutoDisposeFutureProviderRef<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>;
String _$collectionActiveItemsHash() =>
    r'90c36a8d4a33c8f8dd5b4927e7dd2ec826283fd3';

/// See also [collectionActiveItems].
@ProviderFor(collectionActiveItems)
final collectionActiveItemsProvider = AutoDisposeFutureProvider<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>.internal(
  collectionActiveItems,
  name: r'collectionActiveItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionActiveItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CollectionActiveItemsRef = AutoDisposeFutureProviderRef<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>;
String _$collectionChangesHash() => r'9cdbf00aee59ae6661f58a392677e0a6aa07d663';

/// See also [CollectionChanges].
@ProviderFor(CollectionChanges)
final collectionChangesProvider =
    StreamNotifierProvider<CollectionChanges, void>.internal(
  CollectionChanges.new,
  name: r'collectionChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionChanges = StreamNotifier<void>;
String _$collectionItemStatusFilterHash() =>
    r'5653bc5b9b99f94eb3c02dd8c60a3bb7e828de1e';

/// See also [CollectionItemStatusFilter].
@ProviderFor(CollectionItemStatusFilter)
final collectionItemStatusFilterProvider = NotifierProvider<
    CollectionItemStatusFilter, Set<MediaCollectionItemStatus>>.internal(
  CollectionItemStatusFilter.new,
  name: r'collectionItemStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionItemStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionItemStatusFilter = Notifier<Set<MediaCollectionItemStatus>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
