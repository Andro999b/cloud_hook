import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/widgets/settings_icon.dart';
import 'package:flutter/material.dart';

typedef LableBuilder = String Function(BuildContext context);

class NavigationRoute {
  const NavigationRoute._(
      {required this.path, required this.icon, required this.lableBuilder});

  final String path;
  final Widget icon;
  final LableBuilder lableBuilder;

  static final home = NavigationRoute._(
    path: "/",
    icon: const Icon(Icons.home),
    lableBuilder: (context) => AppLocalizations.of(context)!.home,
  );
  static final search = NavigationRoute._(
    path: "/search",
    icon: const Icon(Icons.search),
    lableBuilder: (context) => AppLocalizations.of(context)!.search,
  );
  static final collection = NavigationRoute._(
    path: "/collection",
    icon: const Icon(Icons.favorite),
    lableBuilder: (context) => AppLocalizations.of(context)!.collection,
  );
  static final settings = NavigationRoute._(
    path: "/settings",
    icon: const SettingsIcon(),
    lableBuilder: (context) => AppLocalizations.of(context)!.settings,
  );

  static final List<NavigationRoute> routes = [
    home,
    search,
    collection,
    settings
  ];
}
