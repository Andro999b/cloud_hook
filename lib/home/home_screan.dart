import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:flutter/material.dart';

class HomeScrean extends StatelessWidget {
  const HomeScrean({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralLayout(
      selectedIndex: 0,
      child: Center(
        child: Text(AppLocalizations.of(context)!.home),
      ),
    );
  }
}
