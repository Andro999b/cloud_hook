// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionItemCurrentItemHash() =>
    r'4bcd51cabe77270f827bf5d2744bd465ca299de7';

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

/// See also [collectionItemCurrentItem].
@ProviderFor(collectionItemCurrentItem)
const collectionItemCurrentItemProvider = CollectionItemCurrentItemFamily();

/// See also [collectionItemCurrentItem].
class CollectionItemCurrentItemFamily extends Family<AsyncValue<int>> {
  /// See also [collectionItemCurrentItem].
  const CollectionItemCurrentItemFamily();

  /// See also [collectionItemCurrentItem].
  CollectionItemCurrentItemProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentItemProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentItemProvider getProviderOverride(
    covariant CollectionItemCurrentItemProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentItemProvider';
}

/// See also [collectionItemCurrentItem].
class CollectionItemCurrentItemProvider extends AutoDisposeFutureProvider<int> {
  /// See also [collectionItemCurrentItem].
  CollectionItemCurrentItemProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentItem(
            ref as CollectionItemCurrentItemRef,
            contentDetails,
          ),
          from: collectionItemCurrentItemProvider,
          name: r'collectionItemCurrentItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentItemHash,
          dependencies: CollectionItemCurrentItemFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentItemFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<int> Function(CollectionItemCurrentItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentItemProvider._internal(
        (ref) => create(ref as CollectionItemCurrentItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _CollectionItemCurrentItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentItemProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CollectionItemCurrentItemRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentItemProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with CollectionItemCurrentItemRef {
  _CollectionItemCurrentItemProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentItemProvider).contentDetails;
}

String _$collectionItemCurrentSourceHash() =>
    r'96559150e4f67489b458da68144d3010659b2d8e';

/// See also [collectionItemCurrentSource].
@ProviderFor(collectionItemCurrentSource)
const collectionItemCurrentSourceProvider = CollectionItemCurrentSourceFamily();

/// See also [collectionItemCurrentSource].
class CollectionItemCurrentSourceFamily extends Family<AsyncValue<String?>> {
  /// See also [collectionItemCurrentSource].
  const CollectionItemCurrentSourceFamily();

  /// See also [collectionItemCurrentSource].
  CollectionItemCurrentSourceProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentSourceProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentSourceProvider getProviderOverride(
    covariant CollectionItemCurrentSourceProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentSourceProvider';
}

/// See also [collectionItemCurrentSource].
class CollectionItemCurrentSourceProvider
    extends AutoDisposeFutureProvider<String?> {
  /// See also [collectionItemCurrentSource].
  CollectionItemCurrentSourceProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentSource(
            ref as CollectionItemCurrentSourceRef,
            contentDetails,
          ),
          from: collectionItemCurrentSourceProvider,
          name: r'collectionItemCurrentSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentSourceHash,
          dependencies: CollectionItemCurrentSourceFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentSourceFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentSourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<String?> Function(CollectionItemCurrentSourceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentSourceProvider._internal(
        (ref) => create(ref as CollectionItemCurrentSourceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _CollectionItemCurrentSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentSourceProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CollectionItemCurrentSourceRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentSourceProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with CollectionItemCurrentSourceRef {
  _CollectionItemCurrentSourceProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentSourceProvider).contentDetails;
}

String _$collectionItemCurrentPositionHash() =>
    r'a40836469154592616c1cad035aad4ec50bc12a7';

/// See also [collectionItemCurrentPosition].
@ProviderFor(collectionItemCurrentPosition)
const collectionItemCurrentPositionProvider =
    CollectionItemCurrentPositionFamily();

/// See also [collectionItemCurrentPosition].
class CollectionItemCurrentPositionFamily extends Family<AsyncValue<int>> {
  /// See also [collectionItemCurrentPosition].
  const CollectionItemCurrentPositionFamily();

  /// See also [collectionItemCurrentPosition].
  CollectionItemCurrentPositionProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentPositionProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentPositionProvider getProviderOverride(
    covariant CollectionItemCurrentPositionProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentPositionProvider';
}

/// See also [collectionItemCurrentPosition].
class CollectionItemCurrentPositionProvider
    extends AutoDisposeFutureProvider<int> {
  /// See also [collectionItemCurrentPosition].
  CollectionItemCurrentPositionProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentPosition(
            ref as CollectionItemCurrentPositionRef,
            contentDetails,
          ),
          from: collectionItemCurrentPositionProvider,
          name: r'collectionItemCurrentPositionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentPositionHash,
          dependencies: CollectionItemCurrentPositionFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentPositionFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentPositionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<int> Function(CollectionItemCurrentPositionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentPositionProvider._internal(
        (ref) => create(ref as CollectionItemCurrentPositionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _CollectionItemCurrentPositionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentPositionProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CollectionItemCurrentPositionRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentPositionProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with CollectionItemCurrentPositionRef {
  _CollectionItemCurrentPositionProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentPositionProvider).contentDetails;
}

String _$collectionItemHash() => r'41775e3ea9ba120ead9d8a7d0e816304cf8617c7';

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
