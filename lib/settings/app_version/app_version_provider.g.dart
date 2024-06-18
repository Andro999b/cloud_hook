// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionDownloadAssets _$AppVersionDownloadAssetsFromJson(
        Map<String, dynamic> json) =>
    AppVersionDownloadAssets(
      browserDownloadUrl: json['browser_download_url'] as String,
      name: json['name'] as String,
    );

LatestAppVersionInfo _$LatestAppVersionInfoFromJson(
        Map<String, dynamic> json) =>
    LatestAppVersionInfo(
      name: json['name'] as String,
      assets: (json['assets'] as List<dynamic>)
          .map((e) =>
              AppVersionDownloadAssets.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentAppVersionHash() => r'b9decd7018b899e50f980ac99dd815d6a284f8ba';

/// See also [currentAppVersion].
@ProviderFor(currentAppVersion)
final currentAppVersionProvider = FutureProvider<String>.internal(
  currentAppVersion,
  name: r'currentAppVersionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAppVersionRef = FutureProviderRef<String>;
String _$latestAppVersionInfoHash() =>
    r'2931a43558daf06c0adf1e9f66d31c8acb44fe65';

/// See also [latestAppVersionInfo].
@ProviderFor(latestAppVersionInfo)
final latestAppVersionInfoProvider =
    AutoDisposeFutureProvider<LatestAppVersionInfo>.internal(
  latestAppVersionInfo,
  name: r'latestAppVersionInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestAppVersionInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestAppVersionInfoRef
    = AutoDisposeFutureProviderRef<LatestAppVersionInfo>;
String _$hasNewVersionHash() => r'2960279ab6db7b2b531f3839f4047ffd64680d0e';

/// See also [hasNewVersion].
@ProviderFor(hasNewVersion)
final hasNewVersionProvider = AutoDisposeProvider<bool>.internal(
  hasNewVersion,
  name: r'hasNewVersionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasNewVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasNewVersionRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
