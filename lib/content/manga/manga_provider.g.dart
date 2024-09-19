// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaChapterScansHash() => r'a663928dda93afb8f7e9507a7fef2f333dc0bc02';

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

/// See also [mangaChapterScans].
@ProviderFor(mangaChapterScans)
const mangaChapterScansProvider = MangaChapterScansFamily();

/// See also [mangaChapterScans].
class MangaChapterScansFamily
    extends Family<AsyncValue<List<MangaMediaItemSource>>> {
  /// See also [mangaChapterScans].
  const MangaChapterScansFamily();

  /// See also [mangaChapterScans].
  MangaChapterScansProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return MangaChapterScansProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  MangaChapterScansProvider getProviderOverride(
    covariant MangaChapterScansProvider provider,
  ) {
    return call(
      provider.contentDetails,
      provider.mediaItems,
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
  String? get name => r'mangaChapterScansProvider';
}

/// See also [mangaChapterScans].
class MangaChapterScansProvider
    extends AutoDisposeFutureProvider<List<MangaMediaItemSource>> {
  /// See also [mangaChapterScans].
  MangaChapterScansProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => mangaChapterScans(
            ref as MangaChapterScansRef,
            contentDetails,
            mediaItems,
          ),
          from: mangaChapterScansProvider,
          name: r'mangaChapterScansProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChapterScansHash,
          dependencies: MangaChapterScansFamily._dependencies,
          allTransitiveDependencies:
              MangaChapterScansFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  MangaChapterScansProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
    required this.mediaItems,
  }) : super.internal();

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  @override
  Override overrideWith(
    FutureOr<List<MangaMediaItemSource>> Function(MangaChapterScansRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaChapterScansProvider._internal(
        (ref) => create(ref as MangaChapterScansRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MangaMediaItemSource>> createElement() {
    return _MangaChapterScansProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChapterScansProvider &&
        other.contentDetails == contentDetails &&
        other.mediaItems == mediaItems;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);
    hash = _SystemHash.combine(hash, mediaItems.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MangaChapterScansRef
    on AutoDisposeFutureProviderRef<List<MangaMediaItemSource>> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _MangaChapterScansProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaMediaItemSource>>
    with MangaChapterScansRef {
  _MangaChapterScansProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as MangaChapterScansProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as MangaChapterScansProvider).mediaItems;
}

String _$mangaChapterScanHash() => r'976a5673c1add99630e0b320ceb9eaf4c41d6dfe';

/// See also [mangaChapterScan].
@ProviderFor(mangaChapterScan)
const mangaChapterScanProvider = MangaChapterScanFamily();

/// See also [mangaChapterScan].
class MangaChapterScanFamily extends Family<AsyncValue<MangaMediaItemSource?>> {
  /// See also [mangaChapterScan].
  const MangaChapterScanFamily();

  /// See also [mangaChapterScan].
  MangaChapterScanProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return MangaChapterScanProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  MangaChapterScanProvider getProviderOverride(
    covariant MangaChapterScanProvider provider,
  ) {
    return call(
      provider.contentDetails,
      provider.mediaItems,
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
  String? get name => r'mangaChapterScanProvider';
}

/// See also [mangaChapterScan].
class MangaChapterScanProvider
    extends AutoDisposeFutureProvider<MangaMediaItemSource?> {
  /// See also [mangaChapterScan].
  MangaChapterScanProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => mangaChapterScan(
            ref as MangaChapterScanRef,
            contentDetails,
            mediaItems,
          ),
          from: mangaChapterScanProvider,
          name: r'mangaChapterScanProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChapterScanHash,
          dependencies: MangaChapterScanFamily._dependencies,
          allTransitiveDependencies:
              MangaChapterScanFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  MangaChapterScanProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
    required this.mediaItems,
  }) : super.internal();

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  @override
  Override overrideWith(
    FutureOr<MangaMediaItemSource?> Function(MangaChapterScanRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaChapterScanProvider._internal(
        (ref) => create(ref as MangaChapterScanRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MangaMediaItemSource?> createElement() {
    return _MangaChapterScanProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChapterScanProvider &&
        other.contentDetails == contentDetails &&
        other.mediaItems == mediaItems;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);
    hash = _SystemHash.combine(hash, mediaItems.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MangaChapterScanRef
    on AutoDisposeFutureProviderRef<MangaMediaItemSource?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _MangaChapterScanProviderElement
    extends AutoDisposeFutureProviderElement<MangaMediaItemSource?>
    with MangaChapterScanRef {
  _MangaChapterScanProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as MangaChapterScanProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as MangaChapterScanProvider).mediaItems;
}

String _$currentMangaReaderChapterHash() =>
    r'87e08e0eeaa3c1f831dd21e2c9ab24a4a49a9d0c';

/// See also [currentMangaReaderChapter].
@ProviderFor(currentMangaReaderChapter)
const currentMangaReaderChapterProvider = CurrentMangaReaderChapterFamily();

/// See also [currentMangaReaderChapter].
class CurrentMangaReaderChapterFamily
    extends Family<AsyncValue<MangaReaderChapter?>> {
  /// See also [currentMangaReaderChapter].
  const CurrentMangaReaderChapterFamily();

  /// See also [currentMangaReaderChapter].
  CurrentMangaReaderChapterProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaReaderChapterProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaReaderChapterProvider getProviderOverride(
    covariant CurrentMangaReaderChapterProvider provider,
  ) {
    return call(
      provider.contentDetails,
      provider.mediaItems,
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
  String? get name => r'currentMangaReaderChapterProvider';
}

/// See also [currentMangaReaderChapter].
class CurrentMangaReaderChapterProvider
    extends AutoDisposeFutureProvider<MangaReaderChapter?> {
  /// See also [currentMangaReaderChapter].
  CurrentMangaReaderChapterProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaReaderChapter(
            ref as CurrentMangaReaderChapterRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaReaderChapterProvider,
          name: r'currentMangaReaderChapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaReaderChapterHash,
          dependencies: CurrentMangaReaderChapterFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaReaderChapterFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaReaderChapterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
    required this.mediaItems,
  }) : super.internal();

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  @override
  Override overrideWith(
    FutureOr<MangaReaderChapter?> Function(
            CurrentMangaReaderChapterRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaReaderChapterProvider._internal(
        (ref) => create(ref as CurrentMangaReaderChapterRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MangaReaderChapter?> createElement() {
    return _CurrentMangaReaderChapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaReaderChapterProvider &&
        other.contentDetails == contentDetails &&
        other.mediaItems == mediaItems;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);
    hash = _SystemHash.combine(hash, mediaItems.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CurrentMangaReaderChapterRef
    on AutoDisposeFutureProviderRef<MangaReaderChapter?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaReaderChapterProviderElement
    extends AutoDisposeFutureProviderElement<MangaReaderChapter?>
    with CurrentMangaReaderChapterRef {
  _CurrentMangaReaderChapterProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaReaderChapterProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaReaderChapterProvider).mediaItems;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
