import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class VideoContentDesktopView extends StatefulWidget {
  final Player player;
  final VideoController videoController;
  final PlaylistController playlistController;

  const VideoContentDesktopView({
    super.key,
    required this.player,
    required this.videoController,
    required this.playlistController,
  });

  @override
  State<VideoContentDesktopView> createState() =>
      _VideoContentDesktopViewState();
}

class _VideoContentDesktopViewState extends State<VideoContentDesktopView> {
  bool pipMode = false;
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
        widget.player.state.position - const Duration(seconds: 60),
      );
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 60),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      widget.player.safeSeek(
        widget.player.state.position - const Duration(seconds: 10),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 10),
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
    return MaterialDesktopVideoControlsTheme(
      normal: _createThemeData(false),
      fullscreen: _createThemeData(true),
      child: Video(
        key: videoStateKey,
        controller: widget.videoController,
        controls: (state) => pipMode
            ? PipVideoControls(
                state,
                onPipExit: _switchToPipMode,
              )
            : MaterialDesktopVideoControls(state),
      ),
    );
  }

  MaterialDesktopVideoControlsThemeData _createThemeData(bool fullscrean) {
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
          playlistSize: playlistController.mediaItems.length,
          contentDetails: playlistController.contentDetails,
        ),
        if (playlistController.mediaItems.length > 1)
          PlayerPlaylistButton(
            playlistController: playlistController,
            contentDetails: playlistController.contentDetails,
          )
      ],
      bottomButtonBar: [
        SkipPrevButton(contentDetails: playlistController.contentDetails),
        const PlayOrPauseButton(),
        SkipNextButton(
          contentDetails: playlistController.contentDetails,
          mediaItems: playlistController.mediaItems,
        ),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        if (!fullscrean)
          MaterialCustomButton(
            onPressed: _switchToPipMode,
            icon: const Icon(Symbols.pip),
          ),
        SourceSelector(
          mediaItems: playlistController.mediaItems,
          contentDetails: playlistController.contentDetails,
        ),
        const MaterialDesktopFullscreenButton(),
      ],
      keyboardShortcuts: _keyboardShortcuts,
    );
  }

  void _switchToPipMode() async {
    setState(() {
      pipMode = !pipMode;
    });

    if (!pipMode) {
      // Exit PiP Mode
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setSize(const Size(1280, 720));
      await windowManager.setAlwaysOnTop(false);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlignment(Alignment.center);
    } else {
      // Enter PiP Mode
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setSize(const Size(576, 324));
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlignment(Alignment.bottomRight);
    }
  }
}

class PipVideoControls extends StatefulWidget {
  final VideoState state;
  final VoidCallback onPipExit;
  const PipVideoControls(
    this.state, {
    super.key,
    required this.onPipExit,
  });

  @override
  State<PipVideoControls> createState() => _PipVideoControlsState();
}

class _PipVideoControlsState extends State<PipVideoControls> {
  bool uiVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.transparent,
              );
            }),
            if (uiVisible) ...[
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialDesktopCustomButton(
                      onPressed: widget.onPipExit,
                      icon: const Icon(Symbols.pip_exit),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(child: PlayOrPauseButton(iconSize: 48)),
              )
            ]
          ],
        ),
      ),
    );
  }

  void _onEnter() {
    setState(() {
      uiVisible = true;
    });
  }

  void _onExit() {
    setState(() {
      uiVisible = false;
    });
  }
}
