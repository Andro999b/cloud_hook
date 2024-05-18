import 'dart:ui';

import 'package:cloud_hook/app_database.dart';
import 'package:cloud_hook/app_image_cache.dart';
import 'package:cloud_hook/app_init_firebase.dart';
import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_screen.dart';
import 'package:cloud_hook/content/content_details_screen.dart';
import 'package:cloud_hook/content/video_content_screen.dart';
import 'package:cloud_hook/home/home_screan.dart';
import 'package:cloud_hook/layouts/navigation_data.dart';
import 'package:cloud_hook/search/search_screen.dart';
import 'package:cloud_hook/settings/settings_screan.dart';
import 'package:cloud_hook/utils/error_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init media kit
  MediaKit.ensureInitialized();

  await AppDatabase.init();
  await AppImageCache.init();
  await AppPreferences.init();

  // init firebase
  await AppInitFirebase.init();

  // start ui
  runApp(ProviderScope(
    observers: [ErrorProviderObserver()],
    child: const MainApp(),
  ));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad
      }),
      routerConfig: GoRouter(
          navigatorKey: _rootNavigatorKey,
          // initialLocation: "/search",
          // initialLocation: "/collection",
          // // initialLocation: "/settings",
          // initialLocation: "/content/UAKinoClub/franchise%2F140-shrek",
          // initialLocation: "/video/UAFilmsTV/18323-utawarerumono",
          routes: [
            GoRoute(
              path: NavigationRoute.home.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScrean(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.search.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchScreen(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.collection.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CollectionScreen(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.settings.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScrean(),
              ),
            ),
            GoRoute(
              path: "/content/:supplier/:id",
              pageBuilder: (context, state) => NoTransitionPage(
                child: ContentDetailsScreen(
                  supplier: state.pathParameters["supplier"]!,
                  id: state.pathParameters["id"]!,
                ),
              ),
            ),
            GoRoute(
              path: "/video/:supplier/:id",
              pageBuilder: (context, state) => NoTransitionPage(
                child: VideoContentScreen(
                  supplier: state.pathParameters["supplier"]!,
                  id: state.pathParameters["id"]!,
                ),
              ),
            )
          ]),
    );
  }
}
