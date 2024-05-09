import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrightnesSwitcher extends ConsumerWidget {
  const BrightnesSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var brightness = ref.watch(brigthnesSettingProvider);
    return SegmentedButton<Brightness?>(
      segments: [
        ButtonSegment(
          value: Brightness.light,
          label: Text(AppLocalizations.of(context)!.settingsThemeLight),
          icon: const Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: null,
          label: Text(AppLocalizations.of(context)!.settingsThemeSystem),
          icon: const Icon(Icons.auto_mode),
        ),
        ButtonSegment(
          value: Brightness.dark,
          label: Text(AppLocalizations.of(context)!.settingsThemeDark),
          icon: const Icon(Icons.dark_mode),
        ),
      ],
      selected: {brightness},
      onSelectionChanged: (select) {
        ref.read(brigthnesSettingProvider.notifier).select(select.firstOrNull);
      },
    );
  }
}
