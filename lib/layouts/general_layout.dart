import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/layouts/bottom_navigation_layout.dart';
import 'package:strumok/layouts/side_navigation_layout.dart';
import 'package:strumok/utils/android_tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';

class GeneralLayout extends StatelessWidget {
  const GeneralLayout({
    super.key,
    this.showBackButton = false,
    this.selectedIndex,
    this.floatingActionButton,
    required this.child,
  });

  final bool showBackButton;
  final int? selectedIndex;
  final Widget? floatingActionButton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileWidth) {
              return BottomNavigationLayout(
                selectedIndex: selectedIndex,
                floatingActionButton: floatingActionButton,
                child: child,
              );
            } else {
              return SideNavigationLayout(
                selectedIndex: selectedIndex,
                showBackButton: AndroidTVDetector.isTV ? false : showBackButton,
                child: child,
              );
            }
          },
        ),
      ),
    );
  }
}
