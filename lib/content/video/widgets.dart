import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/fullscreen.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

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

class MediaTitle extends MediaCollectionItemConsumerWidger {
  final int playlistSize;

  const MediaTitle({
    super.key,
    required this.playlistSize,
    required super.contentDetails,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    var title = contentDetails.title;

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

class PlayerPlaylistButton extends MediaCollectionItemConsumerWidger {
  final PlaylistController playlistController;

  const PlayerPlaylistButton({
    super.key,
    required this.playlistController,
    required super.contentDetails,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(MediaItemsListRoute(
          title: AppLocalizations.of(context)!.episodesList,
          mediaItems: playlistController.mediaItems,
          contentProgress: collectionItem,
          onSelect: (item) => playlistController.selectItem(item.number),
        ));
      },
      icon: const Icon(Icons.list),
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class SourceSelector extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;

  const SourceSelector({
    super.key,
    required this.mediaItems,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _SourceSelectDialog(
            mediaItems: mediaItems,
            contentDetails: contentDetails,
          ),
        );
      },
      icon: const Icon(Icons.track_changes),
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class _SourceSelectDialog extends MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;

  const _SourceSelectDialog({
    required this.mediaItems,
    required super.contentDetails,
  });

  @override
  render(BuildContext context, WidgetRef ref, MediaCollectionItem data) {
    return AppTheme(
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder(
          future: Future.value(mediaItems[data.currentItem].sources),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final videos =
                snapshot.data?.where((e) => e.kind == FileKind.video) ?? [];
            final subtitles =
                snapshot.data?.where((e) => e.kind == FileKind.subtitle) ?? [];

            if (videos.isEmpty) {
              return Container(
                width: 250,
                constraints: const BoxConstraints.tightFor(height: 60),
                child: Center(
                  child: Text(AppLocalizations.of(context)!.videoNoSources),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < mobileWidth) {
                  return SingleChildScrollView(
                    child: Column(children: [
                      _renderVideoSources(context, ref, videos, data),
                      if (subtitles.isNotEmpty)
                        _renderSubtitlesSources(context, ref, subtitles, data),
                    ]),
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                          child:
                              _renderVideoSources(context, ref, videos, data)),
                      if (subtitles.isNotEmpty)
                        SingleChildScrollView(
                          child: _renderSubtitlesSources(
                              context, ref, subtitles, data),
                        ),
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _renderVideoSources(
    BuildContext context,
    WidgetRef ref,
    Iterable<ContentMediaItemSource> sources,
    MediaCollectionItem data,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: sources
            .map(
              (e) => MenuItemButton(
                leadingIcon: const Icon(Icons.music_note),
                trailingIcon: data.currentSourceName == e.description
                    ? const Icon(Icons.check)
                    : null,
                onPressed: () {
                  context.pop();
                  final notifier =
                      ref.read(collectionItemProvider(contentDetails).notifier);
                  notifier.setCurrentSource(e.description);
                },
                child: Text(e.description),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _renderSubtitlesSources(
    BuildContext context,
    WidgetRef ref,
    Iterable<ContentMediaItemSource> sources,
    MediaCollectionItem data,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.subtitles),
            trailingIcon: data.currentSubtitleName == null
                ? const Icon(Icons.check)
                : null,
            onPressed: () {
              final notifier =
                  ref.read(collectionItemProvider(contentDetails).notifier);
              notifier.setCurrentSubtitle(null);
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.videoSubtitlesOff),
          ),
          ...sources.map(
            (e) => MenuItemButton(
              leadingIcon: const Icon(Icons.subtitles),
              trailingIcon: data.currentSubtitleName == e.description
                  ? const Icon(Icons.check)
                  : null,
              onPressed: () {
                final notifier =
                    ref.read(collectionItemProvider(contentDetails).notifier);
                notifier.setCurrentSubtitle(e.description);
                context.pop();
              },
              child: Text(e.description),
            ),
          )
        ],
      ),
    );
  }
}

// Prev and Next navigation buttons

class SkipPrevButton extends MediaCollectionItemConsumerWidger {
  final double? iconSize;

  const SkipPrevButton({
    super.key,
    required super.contentDetails,
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
                  .read(collectionItemProvider(contentDetails).notifier)
                  .setCurrentItem(collectionItem.currentItem - 1);
            }
          : null,
      icon: const Icon(Icons.skip_previous),
      iconSize: iconSize,
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class SkipNextButton extends MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;
  final double? iconSize;
  final FocusNode? focusNode;

  const SkipNextButton({
    super.key,
    required this.mediaItems,
    required super.contentDetails,
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
                  .read(collectionItemProvider(contentDetails).notifier)
                  .setCurrentItem(collectionItem.currentItem + 1);
            }
          : null,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.skip_next),
      iconSize: iconSize,
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
      focusNode: focusNode,
    );
  }
}

class PlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final FocusNode? focusNode;

  const PlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.focusNode,
  });

  @override
  PlayOrPauseButtonState createState() => PlayOrPauseButtonState();
}

class PlayOrPauseButtonState extends State<PlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    value: controller(context).player.state.playing ? 1 : 0,
    duration: const Duration(milliseconds: 200),
  );

  StreamSubscription<bool>? subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription ??= controller(context).player.stream.playing.listen((event) {
      if (event) {
        animation.forward();
      } else {
        animation.reverse();
      }
    });
  }

  @override
  void dispose() {
    animation.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      focusNode: widget.focusNode,
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      onPressed: controller(context).player.playOrPause,
      icon: AnimatedIcon(
        progress: animation,
        color: Colors.white,
        icon: AnimatedIcons.play_pause,
        size: widget.iconSize,
      ),
    );
  }
}

Widget videoItemBuilder(
  ContentMediaItem item,
  ContentProgress? contentProgress,
  SelectCallback onSelect,
) {
  final progress = contentProgress?.positions[item.number]?.progress ?? 0;

  return VideoItemsListItem(
    item: item,
    selected: item.number == contentProgress?.currentItem,
    progress: progress,
    onTap: () {
      onSelect(item);
    },
  );
}

class VideoItemsListItem extends StatelessWidget {
  final ContentMediaItem item;
  final bool selected;
  final double progress;
  final VoidCallback onTap;

  const VideoItemsListItem({
    super.key,
    required this.item,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item.title;
    final image = item.image;

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: selected ? theme.colorScheme.onInverseSurface : null,
      child: InkWell(
        autofocus: selected,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 96,
              height: 72,
              decoration: BoxDecoration(
                image: image != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(image),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: image == null
                    ? theme.colorScheme.surfaceTint.withOpacity(0.5)
                    : null,
              ),
              child: selected
                  ? const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: LinearProgressIndicator(value: progress),
              ),
            )
          ],
        ),
      ),
    );
  }
}
