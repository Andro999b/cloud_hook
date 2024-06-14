// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionItemHash() => r'54a39ef976ae8eedfa37ca3a7efe1d7f445f6635';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CollectionItem
    extends BuildlessAutoDisposeAsyncNotifier<MediaCollectionItem> {
  late final ContentDetails details;

  FutureOr<MediaCollectionItem> build(
    ContentDetails details,
  );
}

/// See also [CollectionItem].
@ProviderFor(CollectionItem)
const collectionItemProvider = CollectionItemFamily();

/// See also [CollectionItem].
class CollectionItemFamily extends Family<AsyncValue<MediaCollectionItem>> {
  /// See also [CollectionItem].
  const CollectionItemFamily();

  /// See also [CollectionItem].
  CollectionItemProvider call(
    ContentDetails details,
  ) {
    return CollectionItemProvider(
      details,
    );
  }

  @override
  CollectionItemProvider getProviderOverride(
    covariant CollectionItemProvider provider,
  ) {
    return call(
      provider.details,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'collectionItemProvider';
}

/// See also [CollectionItem].
class CollectionItemProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CollectionItem, MediaCollectionItem> {
  /// See also [CollectionItem].
  CollectionItemProvider(
    ContentDetails details,
  ) : this._internal(
          () => CollectionItem()..details = details,
          from: collectionItemProvider,
          name: r'collectionItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemHash,
          dependencies: CollectionItemFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemFamily._allTransitiveDependencies,
          details: details,
        );

  CollectionItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.details,
  }) : super.internal();

  final ContentDetails details;

  @override
  FutureOr<MediaCollectionItem> runNotifierBuild(
    covariant CollectionItem notifier,
  ) {
    return notifier.build(
      details,
    );
  }

  @override
  Override overrideWith(CollectionItem Function() create) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemProvider._internal(
        () => create()..details = details,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        details: details,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CollectionItem, MediaCollectionItem>
      createElement() {
    return _CollectionItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemProvider && other.details == details;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, details.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CollectionItemRef
    on AutoDisposeAsyncNotifierProviderRef<MediaCollectionItem> {
  /// The parameter `details` of this provider.
  ContentDetails get details;
}

class _CollectionItemProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CollectionItem,
        MediaCollectionItem> with CollectionItemRef {
  _CollectionItemProviderElement(super.provider);

  @override
  ContentDetails get details => (origin as CollectionItemProvider).details;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
