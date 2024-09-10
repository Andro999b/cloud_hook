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
    r'a24b093f0b0e4fc197a9bd121251de0bc170693b';

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

String _$currentMangaChapterPageNumHash() =>
    r'2c6cd1be4d5b6ab2a122b85ce1779498d10605e4';

/// See also [currentMangaChapterPageNum].
@ProviderFor(currentMangaChapterPageNum)
const currentMangaChapterPageNumProvider = CurrentMangaChapterPageNumFamily();

/// See also [currentMangaChapterPageNum].
class CurrentMangaChapterPageNumFamily extends Family<AsyncValue<int>> {
  /// See also [currentMangaChapterPageNum].
  const CurrentMangaChapterPageNumFamily();

  /// See also [currentMangaChapterPageNum].
  CurrentMangaChapterPageNumProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaChapterPageNumProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaChapterPageNumProvider getProviderOverride(
    covariant CurrentMangaChapterPageNumProvider provider,
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
  String? get name => r'currentMangaChapterPageNumProvider';
}

/// See also [currentMangaChapterPageNum].
class CurrentMangaChapterPageNumProvider
    extends AutoDisposeFutureProvider<int> {
  /// See also [currentMangaChapterPageNum].
  CurrentMangaChapterPageNumProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaChapterPageNum(
            ref as CurrentMangaChapterPageNumRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaChapterPageNumProvider,
          name: r'currentMangaChapterPageNumProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaChapterPageNumHash,
          dependencies: CurrentMangaChapterPageNumFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaChapterPageNumFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaChapterPageNumProvider._internal(
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
    FutureOr<int> Function(CurrentMangaChapterPageNumRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaChapterPageNumProvider._internal(
        (ref) => create(ref as CurrentMangaChapterPageNumRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _CurrentMangaChapterPageNumProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaChapterPageNumProvider &&
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

mixin CurrentMangaChapterPageNumRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaChapterPageNumProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with CurrentMangaChapterPageNumRef {
  _CurrentMangaChapterPageNumProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaChapterPageNumProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaChapterPageNumProvider).mediaItems;
}

String _$currentMangaChapterPagesHash() =>
    r'447407b802291c15ae719b11bfb7f2042cf122ee';

/// See also [currentMangaChapterPages].
@ProviderFor(currentMangaChapterPages)
const currentMangaChapterPagesProvider = CurrentMangaChapterPagesFamily();

/// See also [currentMangaChapterPages].
class CurrentMangaChapterPagesFamily
    extends Family<AsyncValue<List<ImageProvider<Object>>?>> {
  /// See also [currentMangaChapterPages].
  const CurrentMangaChapterPagesFamily();

  /// See also [currentMangaChapterPages].
  CurrentMangaChapterPagesProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaChapterPagesProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  CurrentMangaChapterPagesProvider getProviderOverride(
    covariant CurrentMangaChapterPagesProvider provider,
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
  String? get name => r'currentMangaChapterPagesProvider';
}

/// See also [currentMangaChapterPages].
class CurrentMangaChapterPagesProvider
    extends AutoDisposeFutureProvider<List<ImageProvider<Object>>?> {
  /// See also [currentMangaChapterPages].
  CurrentMangaChapterPagesProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => currentMangaChapterPages(
            ref as CurrentMangaChapterPagesRef,
            contentDetails,
            mediaItems,
          ),
          from: currentMangaChapterPagesProvider,
          name: r'currentMangaChapterPagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentMangaChapterPagesHash,
          dependencies: CurrentMangaChapterPagesFamily._dependencies,
          allTransitiveDependencies:
              CurrentMangaChapterPagesFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  CurrentMangaChapterPagesProvider._internal(
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
    FutureOr<List<ImageProvider<Object>>?> Function(
            CurrentMangaChapterPagesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaChapterPagesProvider._internal(
        (ref) => create(ref as CurrentMangaChapterPagesRef),
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
  AutoDisposeFutureProviderElement<List<ImageProvider<Object>>?>
      createElement() {
    return _CurrentMangaChapterPagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaChapterPagesProvider &&
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

mixin CurrentMangaChapterPagesRef
    on AutoDisposeFutureProviderRef<List<ImageProvider<Object>>?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaChapterPagesProviderElement
    extends AutoDisposeFutureProviderElement<List<ImageProvider<Object>>?>
    with CurrentMangaChapterPagesRef {
  _CurrentMangaChapterPagesProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaChapterPagesProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaChapterPagesProvider).mediaItems;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
