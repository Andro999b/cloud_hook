import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/settings/app_version/app_version_settings.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings.dart';
import 'package:cloud_hook/settings/theme/brightnes_switcher.dart';
import 'package:cloud_hook/settings/theme/color_switcher.dart';
import 'package:flutter/material.dart';

class SettingsScrean extends StatelessWidget {
  const SettingsScrean({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 3,
      child: _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: ListView(
                children: [
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsTheme,
                    const BrightnesSwitcher(),
                  ),
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsColor,
                    const ColorSwitcher(),
                  ),
                  _renderSection(context, "Версія", const AppVersionSettings()),
                  const SuppliersSettingsSection(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderSection(BuildContext context, String label, Widget section) {
    const padding = EdgeInsets.only(top: 8.0, bottom: 8.0);
    final lableText = Padding(
      padding: padding,
      child: SizedBox(
        width: 200,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lableText,
              Padding(
                padding: padding,
                child: section,
              )
            ],
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              lableText,
              Expanded(
                child: Padding(
                  padding: padding,
                  child: section,
                ),
              )
            ],
          );
        }
      },
    );
  }
}
