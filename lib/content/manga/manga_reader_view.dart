import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/intents.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_controls.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MangaReaderView extends ConsumerStatefulWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  ConsumerState<MangaReaderView> createState() => _MangaReaderViewState();
}

class _MangaReaderViewState extends ConsumerState<MangaReaderView> {
  final transformationController = TransformationController();
  final scrollOffsetController = ScrollOffsetController();

  @override
  Widget build(BuildContext context) {
    final pageProvider = currentMangaChapterPagesProvider(
      widget.contentDetails,
      widget.mediaItems,
    );

    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    return ref.watch(pageProvider).when(
          data: (pages) => _renderReader(
            context,
            ref,
            readerMode,
            pages ?? const [],
          ),
          error: (error, stackTrace) => DisplayError(
            error: error,
            stackTrace: stackTrace,
            onRefresh: () => ref.refresh(pageProvider.future),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(
    BuildContext context,
    WidgetRef ref,
    MangaReaderMode readerMode,
    List<ImageProvider<Object>> pages,
  ) {
    if (pages.isEmpty == true) {
      return Center(
        child: Text(AppLocalizations.of(context)!.mangaUnableToLoadPage),
      );
    }

    return FocusableActionDetector(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): ScrollUpPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ScrollDownPageIntent(),
        SingleActivator(LogicalKeyboardKey.select): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.space): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.digit1):
            SwitchReaderImageMode(MangaReaderScale.fit),
        SingleActivator(LogicalKeyboardKey.digit2):
            SwitchReaderImageMode(MangaReaderScale.fitHeight),
        SingleActivator(LogicalKeyboardKey.digit3):
            SwitchReaderImageMode(MangaReaderScale.fitWidth),
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) =>
              _movePage(readerMode == MangaReaderMode.rightToLeft ? 1 : -1),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) =>
              _movePage(readerMode == MangaReaderMode.rightToLeft ? -1 : 1),
        ),
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) => Navigator.of(context).push(
            MangaReaderControlsRoute(
              contentDetails: widget.contentDetails,
              mediaItems: widget.mediaItems,
            ),
          ),
        ),
        SwitchReaderImageMode: CallbackAction<SwitchReaderImageMode>(
          onInvoke: (intent) => _swithReaderImageMode(intent.mode),
        ),
        ScrollUpPageIntent: CallbackAction<ScrollUpPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, 100),
        ),
        ScrollDownPageIntent: CallbackAction<ScrollDownPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, -100),
        ),
      },
      autofocus: true,
      child: _ReaderGestureDetector(
        transformationController: transformationController,
        child: _InitialPageLoader(
          contentDetails: widget.contentDetails,
          mediaItems: widget.mediaItems,
          builder: (initialPage, pageNumProvider) => switch (readerMode) {
            MangaReaderMode.hotizontalScroll ||
            MangaReaderMode.vericalScroll =>
              _ScrolledView(
                pages: pages,
                initialPage: initialPage,
                transformationController: transformationController,
                scrollOffsetController: scrollOffsetController,
                pageNumProvider: pageNumProvider,
                collectionItemProvider:
                    collectionItemProvider(widget.contentDetails),
              ),
            _ => _PagedView(
                pages: pages,
                initialPage: initialPage,
                transformationController: transformationController,
                pageNumProvider: pageNumProvider,
              ),
          },
        ),
      ),
    );
  }

  void _movePage(int inc) async {
    final chapter = await ref.read(
      currentMangaChapterProvider(widget.contentDetails, widget.mediaItems)
          .future,
    );

    final provider = collectionItemProvider(widget.contentDetails);
    final contentProgress = (await ref.read(provider.future));
    final pos = contentProgress.currentPosition;

    if (chapter != null) {
      final newPos = pos + inc;
      final notifier = ref.read(provider.notifier);

      if (newPos < 0) {
        if (contentProgress.currentItem > 0) {
          notifier.setCurrentItem(contentProgress.currentItem - 1);
        }
      } else if (newPos >= chapter.pageNambers) {
        if (contentProgress.currentItem < widget.mediaItems.length) {
          notifier.setCurrentItem(contentProgress.currentItem + 1);
        }
      } else {
        notifier.setCurrentPosition(newPos, chapter.pageNambers);
      }
    }
  }

  void _swithReaderImageMode(MangaReaderScale mode) {
    ref.read(mangaReaderScaleSettingsProvider.notifier).select(mode);
  }

  void _scrollTo(MangaReaderMode readerMode, double inc) {
    if (readerMode.scroll) {
      scrollOffsetController.animateScroll(
        offset: -inc,
        duration: const Duration(milliseconds: 100),
      );
    } else {
      final value = transformationController.value.clone();
      final scale = ref.read(mangaReaderScaleSettingsProvider);

      switch (scale) {
        case MangaReaderScale.fitWidth:
          transformationController.value = value..translate(0.0, inc);
        case MangaReaderScale.fitHeight:
          transformationController.value = value..translate(inc, 0.0);
        case _:
      }
    }
  }
}

class _ReaderGestureDetector extends ConsumerStatefulWidget {
  final TransformationController transformationController;
  final Widget child;

  const _ReaderGestureDetector({
    required this.transformationController,
    required this.child,
  });

  @override
  ConsumerState<_ReaderGestureDetector> createState() =>
      _ReaderGestureDetectorState();
}

class _ReaderGestureDetectorState
    extends ConsumerState<_ReaderGestureDetector> {
  late TapDownDetails _lastTapDetails;

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTapUp: (details) => switch (readerMode) {
        MangaReaderMode.vertical ||
        MangaReaderMode.vericalScroll =>
          _verticalTapZones(size, details),
        _ => _horizontalTapZones(size, details)
      },
      onLongPress: () {
        Actions.invoke(context, const ShowUIIntent());
      },
      onDoubleTapDown: (details) {
        _lastTapDetails = details;
      },
      onDoubleTap: _toggleZoom,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.transparent,
        child: widget.child,
      ),
    );
  }

  void _horizontalTapZones(Size size, TapUpDetails details) {
    const zoneFraction = 3;
    final screenWidth = size.width;

    if (details.globalPosition.dx < screenWidth / zoneFraction) {
      Actions.invoke(context, const PrevPageIntent());
    } else if (details.globalPosition.dx >
        screenWidth - (screenWidth / zoneFraction)) {
      Actions.invoke(context, const NextPageIntent());
    }
  }

  void _verticalTapZones(Size size, TapUpDetails details) {
    const zoneFraction = 3;
    final screenHeigt = size.height;

    if (details.globalPosition.dy < screenHeigt / zoneFraction) {
      Actions.invoke(context, const PrevPageIntent());
    } else if (details.globalPosition.dy >
        screenHeigt - (screenHeigt / zoneFraction)) {
      Actions.invoke(context, const NextPageIntent());
    }
  }

  void _toggleZoom() {
    final transfomationController = widget.transformationController;
    if (!transfomationController.value.isIdentity()) {
      transfomationController.value = Matrix4.identity();
    } else {
      final position = _lastTapDetails.localPosition;
      // For a 3x zoom
      transfomationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }
}

typedef _InitialPageBuilder = Widget Function(
    int, CurrentMangaChapterPageNumProvider);

class _InitialPageLoader extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final _InitialPageBuilder builder;

  const _InitialPageLoader({
    required this.contentDetails,
    required this.mediaItems,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageNumProvider = currentMangaChapterPageNumProvider(
      contentDetails,
      mediaItems,
    );

    final initialPageFuture = ref.read(pageNumProvider.future);

    return FutureBuilder(
      future: initialPageFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return builder(snapshot.data!, pageNumProvider);
      },
    );
  }
}

class _PagedView extends ConsumerWidget {
  final List<ImageProvider<Object>> pages;
  final TransformationController transformationController;
  final CurrentMangaChapterPageNumProvider pageNumProvider;
  final PageController pageController;

  _PagedView({
    required this.pages,
    required int initialPage,
    required this.transformationController,
    required this.pageNumProvider,
  }) : pageController = PageController(initialPage: initialPage);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    ref.listen(
      pageNumProvider,
      (previous, next) {
        if (next.hasValue) {
          final pageNum = next.requireValue;

          precacheImage(pages[pageNum], context);
          for (int i = 1; i < 2; i++) {
            final r = pageNum + i;
            final l = pageNum - i;

            if (r < pages.length) {
              precacheImage(pages[r], context);
            }

            if (l >= 0) {
              precacheImage(pages[l], context);
            }
          }

          pageController.animateToPage(
            pageNum,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
    );

    return PageView.builder(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      reverse: readerMode == MangaReaderMode.rightToLeft,
      itemBuilder: (context, index) {
        return _SinglePageView(
          page: pages[index],
          transformationController: transformationController,
        );
      },
      itemCount: pages.length,
      scrollDirection: readerMode == MangaReaderMode.vertical
          ? Axis.vertical
          : Axis.horizontal,
    );
  }
}

class _SinglePageView extends ConsumerWidget {
  final ImageProvider<Object> page;
  final TransformationController transformationController;

  const _SinglePageView({
    required this.page,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(mangaReaderScaleSettingsProvider);

    transformationController.value = Matrix4.diagonal3Values(1, 1, 1);

    return LayoutBuilder(builder: (context, constraints) {
      return InteractiveViewer(
        minScale: 1,
        constrained: false,
        transformationController: transformationController,
        boundaryMargin: switch (scale) {
          MangaReaderScale.fitWidth => EdgeInsets.symmetric(
              vertical: constraints.maxHeight * 2, horizontal: 0),
          MangaReaderScale.fitHeight => EdgeInsets.symmetric(
              vertical: 0, horizontal: constraints.maxHeight * 2),
          _ => EdgeInsets.zero
        },
        child: _PageImage(
          constraints: constraints,
          scale: scale,
          page: page,
        ),
      );
    });
  }
}

class _PageImage extends StatelessWidget {
  final BoxConstraints constraints;
  final MangaReaderScale scale;
  final ImageProvider<Object> page;

  const _PageImage({
    required this.constraints,
    required this.scale,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: constraints.maxHeight,
        minWidth: constraints.maxWidth,
      ),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: switch (scale) {
          MangaReaderScale.fitHeight ||
          MangaReaderScale.fit =>
            constraints.maxHeight,
          _ => null
        },
        width: switch (scale) {
          MangaReaderScale.fitWidth ||
          MangaReaderScale.fit =>
            constraints.maxWidth,
          _ => null
        },
        child: Image(
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(child: CircularProgressIndicator());
          },
          fit: switch (scale) {
            MangaReaderScale.fitHeight => BoxFit.fitHeight,
            MangaReaderScale.fitWidth => BoxFit.fitWidth,
            _ => BoxFit.contain
          },
          image: page,
        ),
      ),
    );
  }
}

class _ScrolledView extends ConsumerStatefulWidget {
  final List<ImageProvider<Object>> pages;
  final int initialPage;
  final TransformationController transformationController;
  final ScrollOffsetController scrollOffsetController;
  final CurrentMangaChapterPageNumProvider pageNumProvider;
  final CollectionItemProvider collectionItemProvider;

  const _ScrolledView({
    required this.pages,
    required this.initialPage,
    required this.scrollOffsetController,
    required this.transformationController,
    required this.pageNumProvider,
    required this.collectionItemProvider,
  });

  @override
  ConsumerState<_ScrolledView> createState() => _ScrolledViewState();
}

class _ScrolledViewState extends ConsumerState<_ScrolledView> {
  bool isScaling = false;
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    widget.transformationController.addListener(_onTransformationChange);
    _itemPositionsListener.itemPositions.addListener(_onPositionChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_onTransformationChange);
    _itemPositionsListener.itemPositions.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    final curItem = _itemPositionsListener.itemPositions.value.lastOrNull;

    if (curItem == null) {
      return;
    }

    ref
        .read(widget.collectionItemProvider.notifier)
        .setCurrentPosition(curItem.index);
  }

  void _onTransformationChange() {
    final newIsScale = !widget.transformationController.value.isIdentity();
    if (newIsScale != isScaling) {
      setState(() {
        isScaling = newIsScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    return LayoutBuilder(builder: (context, constraints) {
      return InteractiveViewer(
        transformationController: widget.transformationController,
        scaleEnabled: isScaling,
        panEnabled: isScaling,
        child: ScrollablePositionedList.separated(
          separatorBuilder: (context, index) =>
              const SizedBox.square(dimension: 8),
          scrollDirection: readerMode == MangaReaderMode.hotizontalScroll
              ? Axis.horizontal
              : Axis.vertical,
          scrollOffsetController: widget.scrollOffsetController,
          itemPositionsListener: _itemPositionsListener,
          physics: isScaling ? const NeverScrollableScrollPhysics() : null,
          itemCount: widget.pages.length,
          initialScrollIndex: widget.initialPage,
          itemBuilder: (context, index) => Image(image: widget.pages[index]),
        ),
      );
    });
  }
}
