import 'package:cloud_hook/app_secrets.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_provider.g.dart';

@Riverpod(keepAlive: true)
FutureOr<String> currentAppVersion(CurrentAppVersionRef ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

@JsonSerializable(createToJson: false)
class AppVersionDownloadAssets {
  @JsonKey(name: "browser_download_url")
  final String browserDownloadUrl;
  final String name;

  AppVersionDownloadAssets({
    required this.browserDownloadUrl,
    required this.name,
  });

  factory AppVersionDownloadAssets.fromJson(Map<String, dynamic> json) =>
      _$AppVersionDownloadAssetsFromJson(json);
}

@JsonSerializable(createToJson: false)
class LatestAppVersionInfo {
  final String name;
  final List<AppVersionDownloadAssets> assets;

  LatestAppVersionInfo({
    required this.name,
    required this.assets,
  });

  factory LatestAppVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$LatestAppVersionInfoFromJson(json);
}

@riverpod
FutureOr<LatestAppVersionInfo> latestAppVersionInfo(
    LatestAppVersionInfoRef ref) async {
  final appVersionCheckURL = AppSecrets.getString("appVersionCheckURL");
  final res = await Dio().get(appVersionCheckURL);
  return LatestAppVersionInfo.fromJson(res.data);
}

@riverpod
bool hasNewVersion(HasNewVersionRef ref) {
  final currentVersion = ref.watch(currentAppVersionProvider).valueOrNull;
  final latestVersionInfo = ref.watch(latestAppVersionInfoProvider).valueOrNull;

  if (currentVersion == null || latestVersionInfo == null) {
    return false;
  }

  return currentVersion != latestVersionInfo.name.substring(1);
}
