import 'package:cloud_hook/layouts/navigation_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationLayout extends StatelessWidget {
  const BottomNavigationLayout({
    super.key,
    this.selectedIndex,
    required this.child,
  });

  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var routes = NavigationRoute.routes
        .map((r) => NavigationDestination(
              icon: Icon(r.icon),
              label: r.lableBuilder(context),
            ))
        .toList();

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex ?? 0,
        destinations: [...routes],
        onDestinationSelected: (index) =>
            context.go(NavigationRoute.routes[index].path),
      ),
      // floatingActionButton: AuthIcon(),
    );
  }
}
