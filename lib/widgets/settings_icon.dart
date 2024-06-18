import 'package:cloud_hook/settings/app_version/app_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsIcon extends ConsumerWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNewVersion = ref.watch(hasNewVersionProvider);

    if (hasNewVersion) {
      return const Badge(child: Icon(Icons.settings));
    }

    return const Icon(Icons.settings);
  }
}
