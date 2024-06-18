import 'package:cloud_hook/auth/auth_icon.dart';
import 'package:cloud_hook/layouts/navigation_data.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideNavigationLayout extends StatelessWidget {
  const SideNavigationLayout({
    super.key,
    this.selectedIndex,
    this.showBackButton = false,
    required this.child,
  });

  final bool showBackButton;
  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final routes = NavigationRoute.routes
        .map(
          (r) => NavigationRailDestination(
            icon: r.icon,
            label: Text(r.lableBuilder(context)),
          ),
        )
        .toList();

    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: NavigationRail(
              leading:
                  showBackButton ? const BackNavButton() : const AuthIcon(),
              trailing: const SizedBox.square(dimension: 48),
              selectedIndex: selectedIndex,
              groupAlignment: 0.0,
              destinations: routes,
              onDestinationSelected: (index) =>
                  context.go(NavigationRoute.routes[index].path),
            ),
          ),
          Expanded(child: child)
        ],
      ),
    );
  }
}
