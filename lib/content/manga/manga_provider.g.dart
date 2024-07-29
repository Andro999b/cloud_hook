// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentMangaChaptersHash() =>
    r'40449425811893cea388455d928afc5f70b4d655';

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

/// See also [currentMangaChapters].
@ProviderFor(currentMangaChapters)
const currentMangaChaptersProvider = CurrentMangaChaptersFamily();

/// See also [currentMangaChapters].
class CurrentMangaChaptersFamily
    extends Family<AsyncValue<List<MangaMediaItemSource>>> {
  /// See also [currentMangaChapters].
  const CurrentMangaChaptersFamily();

  /// See also [currentMangaChapters].
  CurrentMangaChaptersProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaChaptersProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaChaptersProvider getProviderOverride(
    covariant CurrentMangaChaptersProvider provider,
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
  String? get name => r'currentMangaChaptersProvider';
}

/// See also [currentMangaChapters].
class CurrentMangaChaptersProvider
    extends AutoDisposeFutureProvider<List<MangaMediaItemSource>> {
  /// See also [currentMangaChapters].
  CurrentMangaChaptersProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaChapters(
            ref as CurrentMangaChaptersRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaChaptersProvider,
          name: r'currentMangaChaptersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaChaptersHash,
          dependencies: CurrentMangaChaptersFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaChaptersFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaChaptersProvider._internal(
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
    FutureOr<List<MangaMediaItemSource>> Function(
            CurrentMangaChaptersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaChaptersProvider._internal(
        (ref) => create(ref as CurrentMangaChaptersRef),
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
    return _CurrentMangaChaptersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaChaptersProvider &&
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

mixin CurrentMangaChaptersRef
    on AutoDisposeFutureProviderRef<List<MangaMediaItemSource>> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaChaptersProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaMediaItemSource>>
    with CurrentMangaChaptersRef {
  _CurrentMangaChaptersProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaChaptersProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaChaptersProvider).mediaItems;
}

String _$currentMangaChapterHash() =>
    r'dda894c0edb3f9e0ae03245c10e9b00dbf62e06a';

/// See also [currentMangaChapter].
@ProviderFor(currentMangaChapter)
const currentMangaChapterProvider = CurrentMangaChapterFamily();

/// See also [currentMangaChapter].
class CurrentMangaChapterFamily
    extends Family<AsyncValue<MangaMediaItemSource?>> {
  /// See also [currentMangaChapter].
  const CurrentMangaChapterFamily();

  /// See also [currentMangaChapter].
  CurrentMangaChapterProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaChapterProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaChapterProvider getProviderOverride(
    covariant CurrentMangaChapterProvider provider,
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
  String? get name => r'currentMangaChapterProvider';
}

/// See also [currentMangaChapter].
class CurrentMangaChapterProvider
    extends AutoDisposeFutureProvider<MangaMediaItemSource?> {
  /// See also [currentMangaChapter].
  CurrentMangaChapterProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaChapter(
            ref as CurrentMangaChapterRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaChapterProvider,
          name: r'currentMangaChapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaChapterHash,
          dependencies: CurrentMangaChapterFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaChapterFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaChapterProvider._internal(
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
    FutureOr<MangaMediaItemSource?> Function(CurrentMangaChapterRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaChapterProvider._internal(
        (ref) => create(ref as CurrentMangaChapterRef),
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
    return _CurrentMangaChapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaChapterProvider &&
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

mixin CurrentMangaChapterRef
    on AutoDisposeFutureProviderRef<MangaMediaItemSource?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaChapterProviderElement
    extends AutoDisposeFutureProviderElement<MangaMediaItemSource?>
    with CurrentMangaChapterRef {
  _CurrentMangaChapterProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaChapterProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaChapterProvider).mediaItems;
}

String _$currentMangaPageHash() => r'279df0ba0a7b2fdb8f78639b42b85873843d2f4f';

/// See also [currentMangaPage].
@ProviderFor(currentMangaPage)
const currentMangaPageProvider = CurrentMangaPageFamily();

/// See also [currentMangaPage].
class CurrentMangaPageFamily extends Family<AsyncValue<MangaChapterPages?>> {
  /// See also [currentMangaPage].
  const CurrentMangaPageFamily();

  /// See also [currentMangaPage].
  CurrentMangaPageProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaPageProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaPageProvider getProviderOverride(
    covariant CurrentMangaPageProvider provider,
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
  String? get name => r'currentMangaPageProvider';
}

/// See also [currentMangaPage].
class CurrentMangaPageProvider
    extends AutoDisposeFutureProvider<MangaChapterPages?> {
  /// See also [currentMangaPage].
  CurrentMangaPageProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaPage(
            ref as CurrentMangaPageRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaPageProvider,
          name: r'currentMangaPageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaPageHash,
          dependencies: CurrentMangaPageFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaPageFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaPageProvider._internal(
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
    FutureOr<MangaChapterPages?> Function(CurrentMangaPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaPageProvider._internal(
        (ref) => create(ref as CurrentMangaPageRef),
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
  AutoDisposeFutureProviderElement<MangaChapterPages?> createElement() {
    return _CurrentMangaPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaPageProvider &&
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

mixin CurrentMangaPageRef on AutoDisposeFutureProviderRef<MangaChapterPages?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaPageProviderElement
    extends AutoDisposeFutureProviderElement<MangaChapterPages?>
    with CurrentMangaPageRef {
  _CurrentMangaPageProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaPageProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaPageProvider).mediaItems;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
