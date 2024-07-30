import 'dart:ui';

import 'package:cloud_hook/app_database.dart';
import 'package:cloud_hook/app_init_firebase.dart';
import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/app_secrets.dart';
import 'package:cloud_hook/collection/collection_screen.dart';
import 'package:cloud_hook/content/content_details_screen.dart';
import 'package:cloud_hook/content/manga/manga_content_screan.dart';
import 'package:cloud_hook/content/video/video_content_screen.dart';
import 'package:cloud_hook/home/home_screan.dart';
import 'package:cloud_hook/layouts/navigation_data.dart';
import 'package:cloud_hook/search/search_screen.dart';
import 'package:cloud_hook/settings/settings_screan.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/error_observer.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init media kit
  MediaKit.ensureInitialized();

  await AppSecrets.init();
  await AppDatabase.init();
  // await AppImageCache.init();
  await AppPreferences.init();
  await AndroidTVDetector.detect();

  // init firebase
  await AppInitFirebase.init();

  if (isDesktopDevice()) {
    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // start ui
  runApp(ProviderScope(
    observers: [ErrorProviderObserver()],
    child: const MainApp(),
  ));
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad
        }),
        routerConfig: GoRouter(
            navigatorKey: rootNavigatorKey,
            // initialLocation: "/search",
            // initialLocation: "/collection",
            // initialLocation: "/settings",
            // initialLocation: "/content/AniWave/death-note.z02",
            // initialLocation: "/content/Anitaku/category%2Fisekai-suicide-squad",
            // initialLocation:
            //     "/manga/MangaDex/61f03087-1070-4660-b7f0-d2717f84dc0e",
            // initialLocation: "/video/TMDB/movie%2F54138",
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
              ),
              GoRoute(
                path: "/manga/:supplier/:id",
                pageBuilder: (context, state) => NoTransitionPage(
                  child: MangaContentScrean(
                    supplier: state.pathParameters["supplier"]!,
                    id: state.pathParameters["id"]!,
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
