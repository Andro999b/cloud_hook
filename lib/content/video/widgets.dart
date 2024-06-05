import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/fullscreen.dart';

abstract class _MediaCollectionItemConsumerWidger extends ConsumerWidget {
  final CollectionItemProvider provider;

  const _MediaCollectionItemConsumerWidger({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProgress = ref.watch(provider);

    return currentProgress.maybeWhen(
      data: (data) => render(context, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  );
}

// custom exit button to ensure exit fullscreen

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: Colors.white,
      onPressed: () async {
        if (isFullscreen(context)) {
          await exitFullscreen(context);
        }

        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go("/");
          }
        }
      },
    );
  }
}

// Title

class MediaTitle extends _MediaCollectionItemConsumerWidger {
  final ContentDetails details;
  final int playlistSize;

  const MediaTitle({
    super.key,
    required this.details,
    required this.playlistSize,
    required super.provider,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    var title = details.title;

    if (playlistSize > 1) {
      title += " - ${collectionItem.currentItem + 1} / $playlistSize";
    }

    return Expanded(
      child: Text(
        title,
        style: const TextStyle(
          height: 1.0,
          fontSize: 22.0,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Playlist and source selection

class PlaylistButton extends ConsumerWidget {
  final PlaylistController playlistController;
  final CollectionItemProvider provider;

  const PlaylistButton({
    super.key,
    required this.playlistController,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialCustomButton(
      onPressed: () {
        final contentProgress = ref.read(provider).valueOrNull;

        Navigator.of(context).push(MediaItemsListRoute(
          mediaItems: playlistController.mediaItems,
          contentProgress: contentProgress,
          onSelect: (item) => playlistController.selectItem(item.number),
        ));
      },
      icon: const Icon(Icons.list),
    );
  }
}

class SourceSelector extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;

  const SourceSelector({
    super.key,
    required this.mediaItems,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialCustomButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _SourceSelectDialog(
            mediaItems: mediaItems,
            provider: provider,
          ),
        );
      },
      icon: const Icon(Icons.track_changes),
    );
  }
}

class _SourceSelectDialog extends _MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;

  const _SourceSelectDialog({
    required this.mediaItems,
    required super.provider,
  });

  @override
  render(BuildContext context, WidgetRef ref, MediaCollectionItem data) {
    return AppTheme(
      child: BackButtonListener(
        onBackButtonPressed: () async {
          Navigator.of(context).maybePop();
          return true;
        },
        child: Center(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 300,
              child: FutureBuilder(
                future: Future.value(mediaItems[data.currentItem].sources),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error!.toString()));
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data!
                        .mapIndexed(
                          (idx, e) => MenuItemButton(
                            trailingIcon: data.currentSource == idx
                                ? const Icon(Icons.check)
                                : null,
                            onPressed: () {
                              context.pop();
                              final notifier = ref.read(provider.notifier);
                              notifier.setCurrentSource(idx);
                            },
                            child: Text(e.description),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Prev and Next navigation buttons

class SkipPrevButton extends _MediaCollectionItemConsumerWidger {
  final double? iconSize;

  const SkipPrevButton({
    super.key,
    required super.provider,
    this.iconSize,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    return IconButton(
      onPressed: collectionItem.currentItem > 0
          ? () {
              ref
                  .read(provider.notifier)
                  .setCurrentItem(collectionItem.currentItem - 1);
            }
          : null,
      icon: const Icon(Icons.skip_previous),
      iconSize: iconSize,
      color: Colors.white,
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class SkipNextButton extends _MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;
  final double? iconSize;
  final FocusNode? focusNode;

  const SkipNextButton({
    super.key,
    required this.mediaItems,
    required super.provider,
    this.iconSize,
    this.focusNode,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    return IconButton(
      onPressed: collectionItem.currentItem < mediaItems.length - 1
          ? () {
              ref
                  .read(provider.notifier)
                  .setCurrentItem(collectionItem.currentItem + 1);
            }
          : null,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.skip_next),
      iconSize: iconSize,
      color: Colors.white,
      disabledColor: Colors.white.withOpacity(0.7),
      focusNode: focusNode,
    );
  }
}
