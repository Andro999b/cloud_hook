import 'dart:async';

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
    return IconButton(
      onPressed: () {
        final contentProgress = ref.read(provider).valueOrNull;

        Navigator.of(context).push(MediaItemsListRoute(
          mediaItems: playlistController.mediaItems,
          contentProgress: contentProgress,
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
  final CollectionItemProvider provider;

  const SourceSelector({
    super.key,
    required this.mediaItems,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
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

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error!.toString()));
                }

                final videos =
                    snapshot.data!.where((e) => e.kind == FileKind.video);
                final subtitles =
                    snapshot.data!.where((e) => e.kind == FileKind.subtitle);

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
                            _renderSubtitlesSources(
                                context, ref, subtitles, data),
                        ]),
                      );
                    } else {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                              child: _renderVideoSources(
                                  context, ref, videos, data)),
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
            .mapIndexed(
              (idx, e) => MenuItemButton(
                leadingIcon: const Icon(Icons.music_note),
                trailingIcon:
                    data.currentSource == idx ? const Icon(Icons.check) : null,
                onPressed: () {
                  context.pop();
                  final notifier = ref.read(provider.notifier);
                  notifier.setCurrentSource(idx);
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
            trailingIcon:
                data.currentSubtitle == null ? const Icon(Icons.check) : null,
            onPressed: () {
              final notifier = ref.read(provider.notifier);
              notifier.setCurrentSubtitle(null);
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.videoSubtitlesOff),
          ),
          ...sources.mapIndexed(
            (idx, e) => MenuItemButton(
              leadingIcon: const Icon(Icons.subtitles),
              trailingIcon:
                  data.currentSubtitle == idx ? const Icon(Icons.check) : null,
              onPressed: () {
                final notifier = ref.read(provider.notifier);
                notifier.setCurrentSubtitle(idx);
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
      focusColor: Colors.white.withOpacity(0.4),
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
      ),
    );
  }
}
