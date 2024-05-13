import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentView extends ConsumerStatefulWidget {
  final ContentDetails details;
  final List<ContentMediaItem> mediaItems;

  const VideoContentView({
    super.key,
    required this.details,
    required this.mediaItems,
  });

  @override
  ConsumerState<VideoContentView> createState() => _VideoContentViewState();
}

class _VideoContentViewState extends ConsumerState<VideoContentView> {
  final player = Player();
  late final videoController = VideoController(player);
  late final provider = collectionItemProvider(widget.details);
  late ProviderSubscription subscription;
  //dirty hack to catch video state for fullscren shortcuts
  final videoState = ValueNotifier<VideoState?>(null);

  late final _keyboardShortcuts = {
    const SingleActivator(LogicalKeyboardKey.mediaPlay): () => player.play(),
    const SingleActivator(LogicalKeyboardKey.mediaPause): () => player.pause(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
        player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext): () => _prevItem(),
    const SingleActivator(LogicalKeyboardKey.bracketLeft): () => _prevItem(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () =>
        _nextItem(),
    const SingleActivator(LogicalKeyboardKey.bracketRight): () => _nextItem(),
    const SingleActivator(LogicalKeyboardKey.space): () => player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.keyJ): () {
      _seek(player.state.position - const Duration(seconds: 10));
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      _seek(player.state.position + const Duration(seconds: 10));
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      _seek(player.state.position - const Duration(seconds: 2));
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      _seek(player.state.position + const Duration(seconds: 2));
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
      final volume = player.state.volume + 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
      final volume = player.state.volume - 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
    // dirty hack with video state...
    const SingleActivator(LogicalKeyboardKey.keyF): () =>
        _toggleFullsreen(videoState.value!),
    const SingleActivator(LogicalKeyboardKey.enter): () =>
        _toggleFullsreen(videoState.value!),
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        videoState.value!.exitFullscreen()
  };

  void _toggleFullsreen(VideoState videoState) {
    if (videoState.isFullscreen()) {
      videoState.exitFullscreen();
    } else {
      videoState.enterFullscreen();
    }
  }

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(provider.notifier);

    subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null &&
            (previousValue?.currentItem != nextValue.currentItem ||
                previousValue?.currentSource != nextValue.currentSource)) {
          await _playMediaItem(nextValue);
        }
      },
      fireImmediately: true,
    );

    player.stream.completed.listen((event) {
      if (event) {
        _nextItem();
      }
    });

    player.stream.position.listen((event) {
      final position = event.inSeconds;
      final duration = player.state.duration.inSeconds;

      if (position > 0 && duration > 0) {
        notifier.setCurrentPosition(position, duration);
      }
    });

    player.setVolume(AppPreferences.volume);
    player.stream.volume.listen((event) {
      AppPreferences.volume = event;
    });
  }

  @override
  void dispose() {
    subscription.close();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        final mobileThemeData = _createMobileThemeData();
        return MaterialVideoControlsTheme(
          normal: mobileThemeData,
          fullscreen: mobileThemeData,
          child: _renderVideo(),
        );
      default:
        final desktopThemeData = _createDesktopThemeData();
        return MaterialDesktopVideoControlsTheme(
          normal: desktopThemeData,
          fullscreen: desktopThemeData,
          child: _renderVideo(),
        );
    }
  }

  Widget _renderVideo() {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Video(
        controller: videoController,
        controls: (state) {
          // dirty hack to catch vieo state for fullscreen
          videoState.value = state;
          return AdaptiveVideoControls(state);
        },
      ),
    );
  }

  // Mobile theme

  MaterialVideoControlsThemeData _createMobileThemeData() {
    return MaterialVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBarMargin: const EdgeInsets.only(top: 8),
      topButtonBar: [
        _ExitButton(),
        const SizedBox(width: 8),
        _Title(
          details: widget.details,
          playlistSize: widget.mediaItems.length,
          provider: provider,
        ),
        const Spacer(),
        if (widget.mediaItems.length > 1)
          _PlaylistButton(
            mediaItems: widget.mediaItems,
            provider: provider,
            onSelect: (item) {
              _setItemIdx(item.number);
            },
          )
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        _SkipPrevButton(provider: provider),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 48.0),
        const Spacer(),
        _SkipNextButton(
          provider: provider,
          playlistSize: widget.mediaItems.length,
        ),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        _SourceSelector(mediaItems: widget.mediaItems, provider: provider),
        const MaterialFullscreenButton(),
      ],
      seekGesture: true,
      seekOnDoubleTap: true,
    );
  }

  // Desktop theme

  MaterialDesktopVideoControlsThemeData _createDesktopThemeData() {
    const marging = EdgeInsets.symmetric(horizontal: 20.0);
    return MaterialDesktopVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBarMargin: marging.copyWith(top: 8),
      bottomButtonBarMargin: marging,
      topButtonBar: [
        _ExitButton(),
        const SizedBox(width: 8),
        _Title(
          details: widget.details,
          playlistSize: widget.mediaItems.length,
          provider: provider,
        ),
        const Spacer(),
        if (widget.mediaItems.length > 1)
          _PlaylistButton(
            mediaItems: widget.mediaItems,
            provider: provider,
            onSelect: (item) {
              _setItemIdx(item.number);
            },
          )
      ],
      bottomButtonBar: [
        _SkipPrevButton(provider: provider),
        const MaterialDesktopPlayOrPauseButton(),
        _SkipNextButton(
            provider: provider, playlistSize: widget.mediaItems.length),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        _SourceSelector(mediaItems: widget.mediaItems, provider: provider),
        const MaterialDesktopFullscreenButton(),
      ],
      keyboardShortcuts: _keyboardShortcuts,
    );
  }

  void _seek(Duration position) {
    if (position <= Duration.zero) {
      player.seek(Duration.zero);
    } else if (position < player.state.duration) {
      player.seek(position);
    }
  }

  // playback callbacks

  Future<void> _playMediaItem(ContentProgress progress) async {
    try {
      final itemIdx = progress.currentItem;
      final sourceIdx = progress.currentSource;

      final item = widget.mediaItems[itemIdx];
      final sources = await item.sources;

      final sourceIndex = sourceIdx >= sources.length ? 0 : sourceIdx;
      final source = sources[sourceIndex];

      final media = Media(
        source.link.toString(),
        httpHeaders: source.headers,
        start: Duration(seconds: progress.currentPosition),
      );

      await player.open(media);
    } on Exception catch (e, stackTrace) {
      logger.e("Fail to play", error: e, stackTrace: stackTrace);
    }
  }

  void _nextItem() {
    final asyncValue = ref.read(provider);

    asyncValue.whenData((value) {
      _setItemIdx(value.currentItem + 1);
    });
  }

  void _prevItem() {
    final asyncValue = ref.read(provider);

    asyncValue.whenData((value) {
      _setItemIdx(value.currentItem - 1);
    });
  }

  void _setItemIdx(int itemIdx) {
    if (_isValidItemIdx(itemIdx)) {
      return;
    }

    final notifier = ref.read(provider.notifier);

    notifier.setCurrentItem(itemIdx);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < widget.mediaItems.length && itemIdx >= 0;
  }
}

abstract class _MediaCollectionItemConsumerWidger extends ConsumerWidget {
  final CollectionItemProvider provider;

  const _MediaCollectionItemConsumerWidger({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProgress = ref.watch(provider);

    return currentProgress.maybeWhen(
      data: (data) => render(context, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget render(BuildContext context, WidgetRef ref, MediaCollectionItem data);
}

// custom exit button to ensure exit fullscreen

class _ExitButton extends StatelessWidget {
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

class _Title extends _MediaCollectionItemConsumerWidger {
  final ContentDetails details;
  final int playlistSize;

  const _Title({
    required this.details,
    required this.playlistSize,
    required super.provider,
  });

  @override
  Widget render(
      BuildContext context, WidgetRef ref, MediaCollectionItem currentItem) {
    var title = details.title;

    if (playlistSize > 1) {
      title += " - ${currentItem.currentItem + 1} / $playlistSize";
    }

    return Text(
      title,
      style: const TextStyle(
        height: 1.0,
        fontSize: 22.0,
        color: Colors.white,
      ),
    );
  }
}

// Playlist and source selection

class _PlaylistButton extends ConsumerWidget {
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;
  final SelectCallback onSelect;

  const _PlaylistButton({
    required this.mediaItems,
    required this.provider,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialCustomButton(
      onPressed: () {
        final contentProgress = ref.read(provider).valueOrNull;

        Navigator.of(context).push(MediaItemsListRoute(
          mediaItems: mediaItems,
          contentProgress: contentProgress,
          onSelect: onSelect,
        ));
      },
      icon: const Icon(Icons.list),
    );
  }
}

class _SourceSelector extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;

  const _SourceSelector({
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
    );
  }
}

// Prev and Next navigation buttons

class _SkipPrevButton extends _MediaCollectionItemConsumerWidger {
  const _SkipPrevButton({required super.provider});

  @override
  Widget render(BuildContext context, WidgetRef ref, MediaCollectionItem data) {
    return IconButton(
      onPressed: data.currentItem > 0
          ? () {
              ref.read(provider.notifier).setCurrentItem(data.currentItem - 1);
            }
          : null,
      icon: const Icon(Icons.skip_previous),
      color: Colors.white,
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class _SkipNextButton extends _MediaCollectionItemConsumerWidger {
  final int playlistSize;

  const _SkipNextButton({
    required this.playlistSize,
    required super.provider,
  });

  @override
  Widget render(BuildContext context, WidgetRef ref, MediaCollectionItem data) {
    return IconButton(
      onPressed: data.currentItem < playlistSize - 1
          ? () {
              ref.read(provider.notifier).setCurrentItem(data.currentItem + 1);
            }
          : null,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.skip_next),
      color: Colors.white,
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}
