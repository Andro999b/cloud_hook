import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:collection/collection.dart';
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

class MediaTitle extends ConsumerWidget {
  final int playlistSize;
  final ContentDetails contentDetails;

  const MediaTitle({
    super.key,
    required this.playlistSize,
    required this.contentDetails,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .valueOrNull;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    var title = contentDetails.title;

    if (playlistSize > 1) {
      title += " - ${currentItem + 1} / $playlistSize";
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

class PlayerPlaylistButton extends ConsumerWidget {
  final PlayerController playerController;
  final ContentDetails contentDetails;

  const PlayerPlaylistButton({
    super.key,
    required this.playerController,
    required this.contentDetails,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final collectionItem =
        ref.watch(collectionItemProvider(contentDetails)).valueOrNull;

    if (collectionItem == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        Navigator.of(context).push(MediaItemsListRoute(
          title: AppLocalizations.of(context)!.episodesList,
          mediaItems: playerController.mediaItems,
          contentProgress: collectionItem,
          onSelect: (item) => playerController.selectItem(item.number),
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

class _SourceSelectDialog extends ConsumerWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;

  const _SourceSelectDialog({
    required this.mediaItems,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesDataAsync =
        ref.watch(collectionItemProvider(contentDetails).selectAsync((item) => (
              item.currentItem,
              item.currentSourceName,
              item.currentSubtitleName,
            )));

    return AppTheme(
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder(
          future: sourcesDataAsync.then((rec) async {
            final (currentItem, currentSource, currentSubtitle) = rec;
            final sources = await mediaItems[currentItem].sources;

            return (sources, currentSource, currentSubtitle);
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final (sources, currentSource, currentSubtitle) = snapshot.data!;

            final videos = sources.where((e) => e.kind == FileKind.video);
            final subtitles = sources.where((e) => e.kind == FileKind.subtitle);

            if (videos.isEmpty) {
              return Container(
                constraints: const BoxConstraints.tightFor(
                  height: 60,
                  width: 60,
                ),
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
                      _renderVideoSources(context, ref, videos, currentSource),
                      if (subtitles.isNotEmpty)
                        _renderSubtitlesSources(
                            context, ref, subtitles, currentSubtitle),
                    ]),
                  );
                } else {
                  return FocusScope(
                    autofocus: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                            child: _renderVideoSources(
                                context, ref, videos, currentSource)),
                        if (subtitles.isNotEmpty)
                          SingleChildScrollView(
                            child: _renderSubtitlesSources(
                                context, ref, subtitles, currentSubtitle),
                          ),
                      ],
                    ),
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
    String? currentSourceName,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: sources
            .map(
              (e) => ListTile(
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.music_note),
                trailing: currentSourceName == e.description
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  context.pop();
                  final notifier =
                      ref.read(collectionItemProvider(contentDetails).notifier);
                  notifier.setCurrentSource(e.description);
                },
                title: Text(
                  e.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
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
    String? currentSubtitleName,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.subtitles),
            trailing:
                currentSubtitleName == null ? const Icon(Icons.check) : null,
            onTap: () {
              final notifier =
                  ref.read(collectionItemProvider(contentDetails).notifier);
              notifier.setCurrentSubtitle(null);
              context.pop();
            },
            title: Text(AppLocalizations.of(context)!.videoSubtitlesOff),
          ),
          ...sources.map(
            (e) => ListTile(
              visualDensity: VisualDensity.compact,
              leading: const Icon(Icons.subtitles),
              trailing: currentSubtitleName == e.description
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                final notifier =
                    ref.read(collectionItemProvider(contentDetails).notifier);
                notifier.setCurrentSubtitle(e.description);
                context.pop();
              },
              title: Text(
                e.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Prev and Next navigation buttons

class SkipPrevButton extends ConsumerWidget {
  final double? iconSize;
  final ContentDetails contentDetails;

  const SkipPrevButton({
    super.key,
    required this.contentDetails,
    this.iconSize,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .valueOrNull;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: currentItem > 0
          ? () {
              ref
                  .read(collectionItemProvider(contentDetails).notifier)
                  .setCurrentItem(currentItem - 1);
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

class SkipNextButton extends ConsumerWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;
  final double? iconSize;
  final FocusNode? focusNode;

  const SkipNextButton({
    super.key,
    required this.mediaItems,
    required this.contentDetails,
    this.iconSize,
    this.focusNode,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .valueOrNull;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: currentItem < mediaItems.length - 1
          ? () {
              ref
                  .read(collectionItemProvider(contentDetails).notifier)
                  .setCurrentItem(currentItem + 1);
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

class PlayerErrorPopup extends StatelessWidget {
  final PlayerController playerController;

  const PlayerErrorPopup({
    super.key,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerController.errors,
      builder: (context, value, child) {
        if (value.isEmpty) {
          return const SizedBox.shrink();
        }

        return MenuAnchor(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                ),
              ),
            );
          },
          menuChildren: [
            ...value.reversed.take(10).map(
                  (error) => ListTile(
                    title: Text(error),
                  ),
                )
          ],
        );
      },
    );
  }
}
