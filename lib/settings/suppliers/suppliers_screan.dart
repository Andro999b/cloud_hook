import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';

class SuppliersSettingsScrean extends StatelessWidget {
  const SuppliersSettingsScrean({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 3,
      child: _SuppliersSettingsView(),
    );
  }
}

class _SuppliersSettingsView extends StatelessWidget {
  const _SuppliersSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = getPadding(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!AndroidTVDetector.isTV) ...[
                    const BackNavButton(),
                    SizedBox(width: padding),
                  ],
                  Text(
                    AppLocalizations.of(context)!.suppliers,
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              SizedBox(height: padding),
              const SuppliersSettingsSection()
            ],
          ),
        ),
      ),
    );
  }
}
