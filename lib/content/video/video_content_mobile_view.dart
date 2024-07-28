import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentMobileView extends StatefulWidget {
  final Player player;
  final VideoController videoController;
  final PlaylistController playlistController;

  const VideoContentMobileView({
    super.key,
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
          playlistSize: widget.playlistController.mediaItems.length,
          contentDetails: widget.playlistController.contentDetails,
        ),
        const Spacer(),
        if (widget.playlistController.mediaItems.length > 1)
          PlayerPlaylistButton(
            playlistController: widget.playlistController,
            contentDetails: widget.playlistController.contentDetails,
          )
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        SkipPrevButton(
          contentDetails: widget.playlistController.contentDetails,
          iconSize: 36.0,
        ),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 48.0),
        const Spacer(),
        SkipNextButton(
          contentDetails: widget.playlistController.contentDetails,
          mediaItems: widget.playlistController.mediaItems,
          iconSize: 36.0,
        ),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        SourceSelector(
          mediaItems: widget.playlistController.mediaItems,
          contentDetails: widget.playlistController.contentDetails,
        ),
        const MaterialFullscreenButton(),
      ],
      bottomButtonBarMargin: const EdgeInsets.symmetric(horizontal: 16),
      seekGesture: true,
      seekOnDoubleTap: true,
      volumeGesture: true,
      seekBarHeight: 8.0,
    );
  }
}
