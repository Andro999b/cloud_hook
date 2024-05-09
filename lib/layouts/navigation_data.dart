import 'package:cloud_hook/app_localizations.dart';
import 'package:flutter/material.dart';

typedef LableBuilder = String Function(BuildContext context);

class NavigationRoute {
  const NavigationRoute._(
      {required this.path, required this.icon, required this.lableBuilder});

  final String path;
  final IconData icon;
  final LableBuilder lableBuilder;

  static final home = NavigationRoute._(
    path: "/",
    icon: Icons.home,
    lableBuilder: (context) => AppLocalizations.of(context)!.home,
  );
  static final search = NavigationRoute._(
    path: "/search",
    icon: Icons.search,
    lableBuilder: (context) => AppLocalizations.of(context)!.search,
  );
  static final collection = NavigationRoute._(
    path: "/collection",
    icon: Icons.favorite,
    lableBuilder: (context) => AppLocalizations.of(context)!.collection,
  );
  static final settings = NavigationRoute._(
    path: "/settings",
    icon: Icons.settings,
    lableBuilder: (context) => AppLocalizations.of(context)!.settings,
  );

  static final List<NavigationRoute> routes = [
    home,
    search,
    collection,
    settings
  ];
}
