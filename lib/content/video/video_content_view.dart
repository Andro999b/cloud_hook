import 'dart:async';
import 'dart:io';

import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_desktop_view.dart';
import 'package:cloud_hook/content/video/video_content_mobile_view.dart';
import 'package:cloud_hook/content/video/video_content_tv_view.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

const subtitleViewConfiguration = SubtitleViewConfiguration(
  style: TextStyle(
      height: 1.4,
      fontSize: 48.0,
      color: Color(0xffffffff),
      fontWeight: FontWeight.normal,
      backgroundColor: Color(0xaa000000)),
);

extension PlayerExt on Player {
  void safeSeek(Duration position) {
    if (position <= Duration.zero) {
      seek(Duration.zero);
    } else if (position < state.duration) {
      seek(position);
    }
  }
}

class PlayerController {
  final Player player;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<String>> errors = ValueNotifier([]);

  List<ContentMediaItemSource>? currentSources;

  final WidgetRef _ref;

  PlayerController({
    required this.player,
    required this.contentDetails,
    required this.mediaItems,
    required WidgetRef ref,
  }) : _ref = ref;

  Future<void> play(ContentProgress progress) async {
    try {
      isLoading.value = true;
      await player.stop();

      final itemIdx = progress.currentItem;
      final sourceName = progress.currentSourceName;

      final item = mediaItems[itemIdx];
      final sources = await item.sources;
      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      final video = sourceName == null
          ? videos.firstOrNull as MediaFileItemSource?
          : videos.firstWhereOrNull((s) => s.description == sourceName)
              as MediaFileItemSource?;

      if (video == null) {
        throw Exception("Video not found");
      }

      final link = await video.link;

      Duration? start;
      final currentItemPosition = progress.currentMediaItemPosition;
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
      errors.value = [];
      await player.open(media);

      currentSources = sources;

      await setSubtitle(progress.currentSubtitleName);
    } on Exception catch (e, stackTrace) {
      logger.e("Fail to play", error: e, stackTrace: stackTrace);
      player.stop();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSubtitle(String? currentSubtitle) async {
    if (currentSources == null) {
      return;
    }

    if (currentSubtitle == null) {
      await player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }

    final subtitles =
        currentSources!.where((s) => s.kind == FileKind.subtitle).toList();

    final subtitle =
        subtitles.firstWhereOrNull((s) => s.description == currentSubtitle)
            as MediaFileItemSource?;

    if (subtitle != null) {
      await player.setSubtitleTrack(SubtitleTrack.uri(
        subtitle.link.toString(),
        title: subtitle.description,
      ));
    }
  }

  void nextItem() {
    final asyncValue = _ref.read(collectionItemProvider(contentDetails));

    asyncValue.whenData((value) {
      selectItem(value.currentItem + 1);
    });
  }

  void prevItem() {
    final asyncValue = _ref.read(collectionItemProvider(contentDetails));

    asyncValue.whenData((value) {
      selectItem(value.currentItem - 1);
    });
  }

  void selectItem(int itemIdx) {
    if (!_isValidItemIdx(itemIdx)) {
      return;
    }

    final notifier = _ref.read(collectionItemProvider(contentDetails).notifier);

    notifier.setCurrentItem(itemIdx);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < mediaItems.length && itemIdx >= 0;
  }

  void addError(String error) {
    errors.value = [...errors.value, error];
  }
}

class VideoContentView extends ConsumerStatefulWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const VideoContentView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  ConsumerState<VideoContentView> createState() => _VideoContentViewState();
}

class _VideoContentViewState extends ConsumerState<VideoContentView> {
  final player = Player();
  late final VideoController videoController;
  late final PlayerController playerController;
  late ProviderSubscription subscription;

  @override
  void initState() {
    super.initState();

    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty("force-seekable", "yes");
    }

    videoController = Platform.isAndroid
        ? VideoController(
            player,
            configuration: const VideoControllerConfiguration(
              vo: "mediacodec_embed",
              hwdec: "mediacodec",
            ),
          )
        : VideoController(player);

    playerController = PlayerController(
      contentDetails: widget.contentDetails,
      player: player,
      mediaItems: widget.mediaItems,
      ref: ref,
    );

    final provider = collectionItemProvider(widget.contentDetails);
    final notifier = ref.read(provider.notifier);

    // track current episode
    subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null) {
          if ((previousValue?.currentItem != nextValue.currentItem ||
              previousValue?.currentSourceName !=
                  nextValue.currentSourceName)) {
            await _playMediaItems(nextValue);
          } else if (previousValue?.currentSubtitleName !=
              nextValue.currentSubtitleName) {
            await playerController.setSubtitle(nextValue.currentSubtitleName);
          }
        }
      },
      fireImmediately: true,
    );

    // track video end
    player.stream.completed.listen((event) {
      if (event) {
        playerController.nextItem();
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
      playerController.addError(event);
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
      await playerController.play(nextValue);
    } catch (_) {
      // show error snackbar
      if (mounted) {
        final error = AppLocalizations.of(context)!.videoSourceFailed;
        playerController.addError(error);

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              behavior: SnackBarBehavior.floating,
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
            valueListenable: playerController.isLoading,
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
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  Widget _renderMobileView() {
    return VideoContentMobileView(
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  Widget _renderDesktopView() {
    return VideoContentDesktopView(
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  // playback callbacks
}
