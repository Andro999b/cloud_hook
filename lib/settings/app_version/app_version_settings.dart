import 'dart:io';

import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/settings/app_version/app_version_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppVersionSettings extends ConsumerWidget {
  const AppVersionSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVersion = ref.watch(currentAppVersionProvider);
    final latestVersionInfo = ref.watch(latestAppVersionInfoProvider);
    final hasNewVersion = ref.watch(hasNewVersionProvider);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        currentVersion.maybeWhen(
          data: (data) => Text(data),
          orElse: () => const SizedBox.shrink(),
        ),
        const Spacer(),
        latestVersionInfo.maybeWhen(
          data: (data) {
            return renderUpdateButton(context, ref, data, hasNewVersion);
          },
          skipLoadingOnRefresh: false,
          loading: () => FilledButton.tonalIcon(
            icon: const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator.adaptive(),
            ),
            onPressed: () {},
            label: const Text("Перевірити оновленя"),
          ),
          orElse: () => const SizedBox.shrink(),
        )
      ],
    );
  }

  Widget renderUpdateButton(
    BuildContext context,
    WidgetRef ref,
    LatestAppVersionInfo latestAppVersionInfo,
    bool hasNewVersion,
  ) {
    if (hasNewVersion) {
      return FilledButton(
        onPressed: () => _downloadNewVersion(context, latestAppVersionInfo),
        child: Text(AppLocalizations.of(context)!
            .settingsDownloadUpdate(latestAppVersionInfo.name)),
      );
    }

    return FilledButton.tonal(
      onPressed: () => ref.refresh(latestAppVersionInfoProvider),
      child: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
    );
  }

  void _downloadNewVersion(
    BuildContext context,
    LatestAppVersionInfo latestAppVersionInfo,
  ) async {
    AppVersionDownloadAssets? asset;
    if (Platform.isLinux || Platform.isWindows) {
      final platform = Platform.isLinux ? "linux" : "windows";

      asset = latestAppVersionInfo.assets
          .where((a) => a.name.contains(platform))
          .firstOrNull;
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      if (deviceInfo.supportedAbis.contains("arm64")) {
        asset = latestAppVersionInfo.assets
            .where((a) => a.name.contains("app-arm64-v8a-release.apk"))
            .firstOrNull;
      } else if (deviceInfo.supportedAbis.contains("arm7")) {
        asset = latestAppVersionInfo.assets
            .where((a) => a.name.contains("app-armeabi-v7a-release.apk"))
            .firstOrNull;
      } else {
        asset = latestAppVersionInfo.assets
            .where((a) => a.name.contains("app-release.apk"))
            .firstOrNull;
      }
    }

    if (asset == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              // ignore: use_build_context_synchronously
              AppLocalizations.of(context)!.settingsUnableDownloadNewVersion),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    launchUrlString(asset.browserDownloadUrl);
  }
}
