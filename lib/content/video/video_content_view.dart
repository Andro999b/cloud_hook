import 'dart:async';

import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_desktop_view.dart';
import 'package:cloud_hook/content/video/video_content_mobile_view.dart';
import 'package:cloud_hook/content/video/video_content_tv_view.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:flutter/material.dart';
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

  PlaylistController({
    required this.provider,
    required this.player,
    required this.mediaItems,
    required this.ref,
  });

  Future<void> play(ContentProgress progress) async {
    try {
      final itemIdx = progress.currentItem;
      final sourceIdx = progress.currentSource;

      final item = mediaItems[itemIdx];
      final sources = await item.sources;

      final sourceIndex = sourceIdx >= sources.length ? 0 : sourceIdx;
      final source = sources[sourceIndex];

      final link = await source.link;

      final media = Media(
        link.toString(),
        httpHeaders: source.headers,
        start: progress.currentPosition > 0
            ? Duration(seconds: progress.currentPosition)
            : null,
      );

      await player.open(media);
    } on Exception catch (e, stackTrace) {
      // TODO: Show toast
      logger.e("Fail to play", error: e, stackTrace: stackTrace);
      player.stop();
      rethrow;
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

    subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null &&
            (previousValue?.currentItem != nextValue.currentItem ||
                previousValue?.currentSource != nextValue.currentSource)) {
          await playlistController.play(nextValue);
        }
      },
      fireImmediately: true,
    );

    player.stream.completed.listen((event) {
      if (event) {
        playlistController.nextItem();
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
    player.stream.volume.listen((event) => AppPreferences.volume = event);
  }

  @override
  void dispose() {
    subscription.close();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final view = switch (Theme.of(context).platform) {
      TargetPlatform.android =>
        AndroidTVDetector.isTV ? _renderTvView() : _renderMobileView(),
      TargetPlatform.iOS => _renderMobileView(),
      _ => _renderDesktopView()
    };

    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: view,
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
