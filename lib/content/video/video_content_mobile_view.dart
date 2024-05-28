import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/video/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentMobileView extends StatefulWidget {
  final CollectionItemProvider provider;
  final ContentDetails details;
  final Player player;
  final VideoController videoController;
  final PlaylistController playlistController;

  const VideoContentMobileView({
    super.key,
    required this.provider,
    required this.details,
    required this.player,
    required this.videoController,
    required this.playlistController,
  });

  @override
  State<VideoContentMobileView> createState() => _VideoContentMobileViewState();
}

class _VideoContentMobileViewState extends State<VideoContentMobileView> {
  late final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoStateKey.currentState?.enterFullscreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _createThemeData();
    return MaterialVideoControlsTheme(
      normal: themeData,
      fullscreen: themeData,
      child: Video(
        key: videoStateKey,
        pauseUponEnteringBackgroundMode: false,
        controller: widget.videoController,
        controls: (state) => MaterialVideoControls(state),
      ),
    );
  }

  MaterialVideoControlsThemeData _createThemeData() {
    return MaterialVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBar: [
        const ExitButton(),
        const SizedBox(width: 8),
        MediaTitle(
          details: widget.details,
          playlistSize: widget.playlistController.mediaItems.length,
          provider: widget.provider,
        ),
        const Spacer(),
        if (widget.playlistController.mediaItems.length > 1)
          PlaylistButton(
            playlistController: widget.playlistController,
            provider: widget.provider,
          )
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        SkipPrevButton(
          provider: widget.provider,
          iconSize: 36.0,
        ),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 48.0),
        const Spacer(),
        SkipNextButton(
          provider: widget.provider,
          enabled: widget.playlistController.canSkipNext,
          iconSize: 36.0,
        ),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        SourceSelector(
          mediaItems: widget.playlistController.mediaItems,
          provider: widget.provider,
        ),
        const MaterialFullscreenButton(),
      ],
      bottomButtonBarMargin: const EdgeInsets.symmetric(horizontal: 16),
      seekGesture: true,
      seekOnDoubleTap: true,
      volumeGesture: true,
    );
  }
}
