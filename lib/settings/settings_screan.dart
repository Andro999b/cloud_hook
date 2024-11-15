import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/settings/app_version/app_version_settings.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_bundle_version_settings.dart';
import 'package:cloud_hook/settings/theme/brightnes_switcher.dart';
import 'package:cloud_hook/settings/theme/color_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                AppLocalizations.of(context)!.settings,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsVersion,
                    const AppVersionSettings(),
                  ),
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsSuppliersVersion,
                    const SuppliersBundleVersionSettings(),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.chevron_right),
                    horizontalTitleGap: 8,
                    title: Text(AppLocalizations.of(context)!.suppliers),
                    onTap: () {
                      context.push("/settings/suppliers");
                    },
                  )
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
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
      ),
    );
  }
}
