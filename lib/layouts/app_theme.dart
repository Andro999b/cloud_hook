import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme extends ConsumerWidget {
  final Widget child;

  const AppTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brigthnesSettingProvider);
    final color = ref.watch(colorSettingsProvider);

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
          seedColor: color,
        ),
        useMaterial3: true,
      ),
      child: child,
    );
  }
}
