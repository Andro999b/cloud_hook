import 'dart:async';

import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_desktop_view.dart';
import 'package:cloud_hook/content/video/video_content_mobile_view.dart';
import 'package:cloud_hook/content/video/video_content_tv_view.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

extension PlayerExt on Player {
  void safeSeek(Duration position) {
    if (position <= Duration.zero) {
      seek(Duration.zero);
    } else if (position < state.duration) {
      seek(position);
    }
  }
}

class PlaylistController {
  final CollectionItemProvider provider;
  final Player player;
  final List<ContentMediaItem> mediaItems;
  final WidgetRef ref;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  List<ContentMediaItemSource>? currentSources;

  PlaylistController({
    required this.provider,
    required this.player,
    required this.mediaItems,
    required this.ref,
  });

  Future<void> play(ContentProgress progress) async {
    try {
      isLoading.value = true;
      await player.stop();

      final itemIdx = progress.currentItem;
      final sourceIdx = progress.currentSource;

      final item = mediaItems[itemIdx];
      final sources = await item.sources;
      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      final sourceIndex = sourceIdx >= sources.length ? 0 : sourceIdx;
      final video = videos.elementAtOrNull(sourceIndex);

      if (video == null) {
        throw Exception("Video not found");
      }

      final link = await video.link;

      Duration? start;
      final currentItemPosition = progress.currentItemPosition;
      if (currentItemPosition.length > 0 &&
          currentItemPosition.position > currentItemPosition.length - 60) {
        start = Duration(seconds: currentItemPosition.length - 60);
      } else {
        start = Duration(seconds: progress.currentPosition);
      }

      final media = Media(
        link.toString(),
        httpHeaders: video.headers,
        start: start,
      );

      isLoading.value = false;
      await player.open(media);

      currentSources = sources;

      await setSubtitle(progress.currentSubtitle);
    } on Exception catch (e, stackTrace) {
      logger.e("Fail to play", error: e, stackTrace: stackTrace);
      player.stop();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSubtitle(int? currentSubtitle) async {
    if (currentSources == null) {
      return;
    }

    if (currentSubtitle == null) {
      await player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }

    final subtitles =
        currentSources!.where((s) => s.kind == FileKind.subtitle).toList();

    final subtitle = subtitles.elementAtOrNull(currentSubtitle);

    if (subtitle != null) {
      await player.setSubtitleTrack(SubtitleTrack.uri(
        subtitle.link.toString(),
        title: subtitle.description,
      ));
    }
  }

  void nextItem() {
    final asyncValue = ref.read(provider);

    asyncValue.whenData((value) {
      selectItem(value.currentItem + 1);
    });
  }

  void prevItem() {
    final asyncValue = ref.read(provider);

    asyncValue.whenData((value) {
      selectItem(value.currentItem - 1);
    });
  }

  void selectItem(int itemIdx) {
    if (!_isValidItemIdx(itemIdx)) {
      return;
    }

    final notifier = ref.read(provider.notifier);

    notifier.setCurrentItem(itemIdx);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < mediaItems.length && itemIdx >= 0;
  }
}

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
  late final VideoController videoController;
  late final PlaylistController playlistController;
  late final provider = collectionItemProvider(widget.details);
  late ProviderSubscription subscription;

  @override
  void initState() {
    super.initState();

    videoController = AndroidTVDetector.isTV
        ? VideoController(
            player,
            configuration: const VideoControllerConfiguration(
              vo: "gpu",
              hwdec: "mediacodec",
            ),
          )
        : VideoController(player);

    playlistController = PlaylistController(
      provider: provider,
      player: player,
      mediaItems: widget.mediaItems,
      ref: ref,
    );

    final notifier = ref.read(provider.notifier);

    // track current episode
    subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null) {
          if ((previousValue?.currentItem != nextValue.currentItem ||
              previousValue?.currentSource != nextValue.currentSource)) {
            await _playMediaItems(nextValue);
          } else if (previousValue?.currentSubtitle !=
              nextValue.currentSubtitle) {
            await playlistController.setSubtitle(nextValue.currentSubtitle);
          }
        }
      },
      fireImmediately: true,
    );

    // track video end
    player.stream.completed.listen((event) {
      if (event) {
        playlistController.nextItem();
      }
    });

    // track video position and duration
    player.stream.position.listen((event) {
      final position = event.inSeconds;
      final duration = player.state.duration.inSeconds;

      if (position > 0 && duration > 0) {
        notifier.setCurrentPosition(position, duration);
      }
    });

    player.setVolume(AppPreferences.volume);
    player.stream.volume.listen((event) => AppPreferences.volume = event);

    player.stream.error.listen((event) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.videoSourceFailed),
          ),
        );
      }
      logger.e("[player]: $event");
    });

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _playMediaItems(MediaCollectionItem nextValue) async {
    try {
      await playlistController.play(nextValue);
    } catch (_) {
      // show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.videoSourceFailed),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    subscription.close();
    player.dispose();
    super.dispose();

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = switch (Theme.of(context).platform) {
      TargetPlatform.android =>
        AndroidTVDetector.isTV ? _renderTvView() : _renderMobileView(),
      TargetPlatform.iOS => _renderMobileView(),
      _ => _renderDesktopView()
    };

    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: Stack(
        children: [
          view,
          ValueListenableBuilder(
            valueListenable: playlistController.isLoading,
            builder: (context, value, child) {
              return value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget _renderTvView() {
    return VideoContentTVView(
      provider: provider,
      details: widget.details,
      player: player,
      videoController: videoController,
      playlistController: playlistController,
    );
  }

  Widget _renderMobileView() {
    return VideoContentMobileView(
      provider: provider,
      details: widget.details,
      player: player,
      videoController: videoController,
      playlistController: playlistController,
    );
  }

  Widget _renderDesktopView() {
    return VideoContentDesktopView(
      provider: provider,
      details: widget.details,
      player: player,
      videoController: videoController,
      playlistController: playlistController,
    );
  }

  // playback callbacks
}
