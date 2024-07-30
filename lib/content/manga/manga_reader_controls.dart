import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MangaReaderControlsRoute<T> extends PopupRoute<T> {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  MangaReaderControlsRoute({
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.3);
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dissmiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: AppTheme(
        child: SafeArea(
          child: MangaReaderControls(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
          ),
        ),
      ),
    );
  }
}

class MangaReaderControls extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderControls({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      _renderTopBar(context, ref),
      const Spacer(),
      MangaReaderBottomBar(
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
    ]);
  }

  Widget _renderTopBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(children: [
        const BackNavButton(),
        const Spacer(),
        _renderVolumesBotton(context, ref),
      ]),
    );
  }

  Widget _renderVolumesBotton(BuildContext context, WidgetRef ref) {
    return VolumesButton(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
      onSelect: (item) {
        final provider = collectionItemProvider(contentDetails);
        ref.read(provider.notifier).setCurrentItem(item.number);
        context.pop();
      },
      autofocus: true,
    );
  }
}
