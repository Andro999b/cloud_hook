import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/android_tv.dart';
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
  Color? get barrierColor => Colors.transparent;
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
      MangaReaderControlTopBar(
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
      const Spacer(),
      MangaReaderControlBottomBar(
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      )
    ]);
  }
}

class MangaReaderControlTopBar extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderControlTopBar({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 8,
          right: 20,
          left: 20,
        ),
        child: Row(children: [
          if (!AndroidTVDetector.isTV) ...[
            BackButton(
              onPressed: () {
                context.go(
                    "/content/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
              },
            ),
            const SizedBox(width: 8),
          ],
          Text(
            contentDetails.title,
            style: theme.textTheme.titleMedium,
          ),
          const Spacer(),
          _renderVolumesBotton(context, ref),
        ]),
      ),
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

class MangaReaderControlBottomBar extends MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;

  const MangaReaderControlBottomBar({
    super.key,
    required super.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    final theme = Theme.of(context);
    final pos = collectionItem.currentMediaItemPosition;

    final curPage = pos.position + 1;
    final pageNumbers = pos.length;
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "$curPage / $pageNumbers",
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MangaReaderSettingsDialog(
                        contentDetails: contentDetails,
                        mediaItems: mediaItems,
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
          ),
          if (pageNumbers > 0) LinearProgressIndicator(value: pos.progress)
        ],
      ),
    );
  }
}
