// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionItemRepositoryHash() =>
    r'de7763e06d4d73f99a9598decbd74c1f38fc6761';

/// See also [collectionItemRepository].
@ProviderFor(collectionItemRepository)
final collectionItemRepositoryProvider =
    Provider<CollectionRepository>.internal(
  collectionItemRepository,
  name: r'collectionItemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionItemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CollectionItemRepositoryRef = ProviderRef<CollectionRepository>;
String _$collectionHash() => r'7ae8fbff22cf8aec1690bee21fd91136ef2ee54b';

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
String _$collectionItemRepositoryChangesHash() =>
    r'eb068ad6981e409664326d2f453c2eacc70d7b03';

/// See also [CollectionItemRepositoryChanges].
@ProviderFor(CollectionItemRepositoryChanges)
final collectionItemRepositoryChangesProvider =
    StreamNotifierProvider<CollectionItemRepositoryChanges, void>.internal(
  CollectionItemRepositoryChanges.new,
  name: r'collectionItemRepositoryChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionItemRepositoryChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionItemRepositoryChanges = StreamNotifier<void>;
String _$collectionItemStatusFilterHash() =>
    r'38fb5a8f9f028e89fb1d28e64366a34318bf4531';

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
