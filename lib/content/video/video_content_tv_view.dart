import 'dart:async';

import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/content/video/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

class VideoContentTVView extends StatelessWidget {
  final CollectionItemProvider provider;
  final ContentDetails details;
  final Player player;
  final VideoController videoController;
  final PlaylistController playlistController;

  const VideoContentTVView({
    super.key,
    required this.provider,
    required this.details,
    required this.player,
    required this.videoController,
    required this.playlistController,
  });

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: videoController,
      controls: (state) => _renderControls(context, state),
    );
  }

  Widget _renderControls(BuildContext context, VideoState state) {
    return AndroidTVControls(
      player: player,
      details: details,
      playlistController: playlistController,
      provider: provider,
    );
  }
}

const seekTransitionDuration = Duration(milliseconds: 500);

class AndroidTVControls extends StatefulWidget {
  const AndroidTVControls({
    super.key,
    required this.player,
    required this.details,
    required this.playlistController,
    required this.provider,
  });

  final Player player;
  final ContentDetails details;
  final PlaylistController playlistController;
  final CollectionItemProvider provider;

  @override
  State<AndroidTVControls> createState() => _AndroidTVControlsState();
}

class _AndroidTVControlsState extends State<AndroidTVControls> {
  late bool mount = false;
  late bool visible = false;

  late bool buffering = controller(context).player.state.buffering;

  FocusNode playPauseFocusNode = FocusNode();
  final List<StreamSubscription> subscriptions = [];

  bool seekVisible = false;
  int seekPosition = 0;
  Timer? _seekTimer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.add(
        controller(context).player.stream.buffering.listen(
          (event) {
            setState(() {
              buffering = event;
            });
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    _seekTimer?.cancel();
    playPauseFocusNode.dispose();
    super.dispose();
  }

  void onEnter() {
    setState(() {
      mount = true;
      visible = true;
    });
    playPauseFocusNode.requestFocus();
  }

  void onExit() {
    setState(() {
      visible = false;
    });
  }

  void seek(int sec) {
    var playerState = widget.player.state;
    int targetPosition =
        seekVisible ? seekPosition : playerState.position.inSeconds;
    targetPosition += sec;

    if (targetPosition < 0) {
      targetPosition = 0;
    } else if (targetPosition > playerState.duration.inSeconds) {
      targetPosition = playerState.duration.inSeconds;
    }

    setState(() {
      seekVisible = true;
      seekPosition = targetPosition;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(seekTransitionDuration, () {
      setState(() {
        seekVisible = false;
      });
      widget.player.safeSeek(Duration(seconds: seekPosition));
    });
  }

  void onBack() {
    if (mount) {
      onExit();
    }
  }

  void onPlayPause() {
    widget.player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        if (!mount) ...{
          const SingleActivator(LogicalKeyboardKey.arrowDown): onEnter,
          const SingleActivator(LogicalKeyboardKey.arrowUp): onEnter,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => seek(-10),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => seek(10),
          const SingleActivator(LogicalKeyboardKey.select): onPlayPause,
        } else ...{
          const SingleActivator(LogicalKeyboardKey.arrowDown): onBack,
          const SingleActivator(LogicalKeyboardKey.arrowUp): onBack,
        }
      },
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (mount) {
            onExit();
            return true;
          }
          return false;
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                onEnd: () {
                  if (!visible) {
                    setState(() {
                      mount = false;
                    });
                  }
                },
                child: mount
                    ? Column(
                        children: [
                          // top bar
                          _renderTopBar(),
                          const Spacer(),
                          // bottom bar
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: MaterialSeekBar(),
                          ),
                          _renderBottomBar()
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              Positioned.fill(child: _renderBufferedIndicator()),
              Positioned.fill(child: _renderSeekPosition()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderBufferedIndicator() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: buffering ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          // Only mount the buffering indicator if the opacity is greater than 0.0.
          // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
          if (value > 0.0) {
            return Opacity(
              opacity: value,
              child: child!,
            );
          }
          return const SizedBox.shrink();
        },
        child: const CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _renderTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0.2,
            1.0,
          ],
          colors: [
            Colors.black26,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          MediaTitle(
            details: widget.details,
            playlistSize: widget.playlistController.mediaItems.length,
            provider: widget.provider,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _renderBottomBar() {
    var canSkipNext = widget.playlistController.canSkipNext;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0,
            1.0,
          ],
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: FocusScope(
        child: Row(
          children: [
            const MaterialDesktopPositionIndicator(),
            const Spacer(),
            SkipPrevButton(provider: widget.provider),
            AndroidTVPlayOrPauseButton(
              focusNode: canSkipNext ? null : playPauseFocusNode,
            ),
            SkipNextButton(
              provider: widget.provider,
              enabled: canSkipNext,
              focusNode: canSkipNext ? playPauseFocusNode : null,
            ),
            const Spacer(),
            SourceSelector(
              mediaItems: widget.playlistController.mediaItems,
              provider: widget.provider,
            ),
            if (widget.playlistController.mediaItems.length > 1)
              PlaylistButton(
                playlistController: widget.playlistController,
                provider: widget.provider,
              )
          ],
        ),
      ),
    );
  }

  _renderSeekPosition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 96),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: seekVisible ? 1.0 : 0,
              duration: const Duration(milliseconds: 200),
              child: _renderSeekText(Duration(seconds: seekPosition).label()),
              onEnd: () {
                if (!seekVisible) {
                  setState(() {
                    seekPosition = 0;
                  });
                }
              },
            )
          ]),
    );
  }

  Text _renderSeekText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 5.0, // shadow blur
            color: Colors.black87,
          ),
        ],
        inherit: true,
      ),
    );
  }
}

class AndroidTVPlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final FocusNode? focusNode;

  const AndroidTVPlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.focusNode,
  });

  @override
  AndroidTVPlayOrPauseButtonState createState() =>
      AndroidTVPlayOrPauseButtonState();
}

class AndroidTVPlayOrPauseButtonState extends State<AndroidTVPlayOrPauseButton>
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
      onPressed: controller(context).player.playOrPause,
      icon: AnimatedIcon(
        progress: animation,
        color: Colors.white,
        icon: AnimatedIcons.play_pause,
      ),
    );
  }
}
