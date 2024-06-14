import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/video/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentDesktopView extends StatefulWidget {
  final CollectionItemProvider provider;
  final ContentDetails details;
  final Player player;
  final VideoController videoController;
  final PlaylistController playlistController;

  const VideoContentDesktopView({
    super.key,
    required this.provider,
    required this.details,
    required this.player,
    required this.videoController,
    required this.playlistController,
  });

  @override
  State<VideoContentDesktopView> createState() =>
      _VideoContentDesktopViewState();
}

class _VideoContentDesktopViewState extends State<VideoContentDesktopView> {
  late final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  late final _keyboardShortcuts = {
    const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
        widget.player.play(),
    const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
        widget.player.pause(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
        widget.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext):
        widget.playlistController.nextItem,
    const SingleActivator(LogicalKeyboardKey.bracketLeft):
        widget.playlistController.prevItem,
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
        widget.playlistController.nextItem,
    const SingleActivator(LogicalKeyboardKey.bracketRight):
        widget.playlistController.nextItem,
    const SingleActivator(LogicalKeyboardKey.space): () =>
        widget.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.keyJ): () {
      widget.player.safeSeek(
        widget.player.state.position - const Duration(seconds: 10),
      );
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 10),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      widget.player.safeSeek(
        widget.player.state.position - const Duration(seconds: 2),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 2),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
      final volume = widget.player.state.volume + 5.0;
      widget.player.setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
      final volume = widget.player.state.volume - 5.0;
      widget.player.setVolume(volume.clamp(0.0, 100.0));
    },
    // dirty hack with video state...
    const SingleActivator(LogicalKeyboardKey.keyF): () =>
        videoStateKey.currentState?.toggleFullscreen(),
    const SingleActivator(LogicalKeyboardKey.enter): () =>
        videoStateKey.currentState?.toggleFullscreen(),
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        videoStateKey.currentState?.exitFullscreen()
  };

  @override
  Widget build(BuildContext context) {
    final desktopThemeData = _createThemeData();
    return MaterialDesktopVideoControlsTheme(
      normal: desktopThemeData,
      fullscreen: desktopThemeData,
      child: Video(
        key: videoStateKey,
        controller: widget.videoController,
        controls: (state) => MaterialDesktopVideoControls(state),
      ),
    );
  }

  MaterialDesktopVideoControlsThemeData _createThemeData() {
    const marging = EdgeInsets.symmetric(horizontal: 20.0);
    final playlistController = widget.playlistController;

    return MaterialDesktopVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBarMargin: marging.copyWith(top: 8),
      bottomButtonBarMargin: marging,
      topButtonBar: [
        const ExitButton(),
        const SizedBox(width: 8),
        MediaTitle(
          details: widget.details,
          playlistSize: playlistController.mediaItems.length,
          provider: widget.provider,
        ),
        if (playlistController.mediaItems.length > 1)
          PlaylistButton(
            playlistController: playlistController,
            provider: widget.provider,
          )
      ],
      bottomButtonBar: [
        SkipPrevButton(provider: widget.provider),
        const PlayOrPauseButton(),
        SkipNextButton(
          provider: widget.provider,
          mediaItems: playlistController.mediaItems,
        ),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        SourceSelector(
          mediaItems: playlistController.mediaItems,
          provider: widget.provider,
        ),
        const MaterialDesktopFullscreenButton(),
      ],
      keyboardShortcuts: _keyboardShortcuts,
    );
  }
}
