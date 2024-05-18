// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recomendations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recomendationChannelHash() =>
    r'11b56ce4f9c5a8c305cd3945a4708a4baae69313';

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

abstract class _$RecomendationChannel
    extends BuildlessAsyncNotifier<RecomendationChannelState> {
  late final String supplierName;
  late final String channel;

  FutureOr<RecomendationChannelState> build(
    String supplierName,
    String channel,
  );
}

/// See also [RecomendationChannel].
@ProviderFor(RecomendationChannel)
const recomendationChannelProvider = RecomendationChannelFamily();

/// See also [RecomendationChannel].
class RecomendationChannelFamily
    extends Family<AsyncValue<RecomendationChannelState>> {
  /// See also [RecomendationChannel].
  const RecomendationChannelFamily();

  /// See also [RecomendationChannel].
  RecomendationChannelProvider call(
    String supplierName,
    String channel,
  ) {
    return RecomendationChannelProvider(
      supplierName,
      channel,
    );
  }

  @override
  RecomendationChannelProvider getProviderOverride(
    covariant RecomendationChannelProvider provider,
  ) {
    return call(
      provider.supplierName,
      provider.channel,
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
  String? get name => r'recomendationChannelProvider';
}

/// See also [RecomendationChannel].
class RecomendationChannelProvider extends AsyncNotifierProviderImpl<
    RecomendationChannel, RecomendationChannelState> {
  /// See also [RecomendationChannel].
  RecomendationChannelProvider(
    String supplierName,
    String channel,
  ) : this._internal(
          () => RecomendationChannel()
            ..supplierName = supplierName
            ..channel = channel,
          from: recomendationChannelProvider,
          name: r'recomendationChannelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recomendationChannelHash,
          dependencies: RecomendationChannelFamily._dependencies,
          allTransitiveDependencies:
              RecomendationChannelFamily._allTransitiveDependencies,
          supplierName: supplierName,
          channel: channel,
        );

  RecomendationChannelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplierName,
    required this.channel,
  }) : super.internal();

  final String supplierName;
  final String channel;

  @override
  FutureOr<RecomendationChannelState> runNotifierBuild(
    covariant RecomendationChannel notifier,
  ) {
    return notifier.build(
      supplierName,
      channel,
    );
  }

  @override
  Override overrideWith(RecomendationChannel Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecomendationChannelProvider._internal(
        () => create()
          ..supplierName = supplierName
          ..channel = channel,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplierName: supplierName,
        channel: channel,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<RecomendationChannel, RecomendationChannelState>
      createElement() {
    return _RecomendationChannelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecomendationChannelProvider &&
        other.supplierName == supplierName &&
        other.channel == channel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplierName.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecomendationChannelRef
    on AsyncNotifierProviderRef<RecomendationChannelState> {
  /// The parameter `supplierName` of this provider.
  String get supplierName;

  /// The parameter `channel` of this provider.
  String get channel;
}

class _RecomendationChannelProviderElement extends AsyncNotifierProviderElement<
    RecomendationChannel,
    RecomendationChannelState> with RecomendationChannelRef {
  _RecomendationChannelProviderElement(super.provider);

  @override
  String get supplierName =>
      (origin as RecomendationChannelProvider).supplierName;
  @override
  String get channel => (origin as RecomendationChannelProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
