import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/intents.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_controls.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MangaReaderView extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CurrentMangaPagesProvider _pagesProvider;
  final CollectionItemProvider _collectionItemProvider;

  MangaReaderView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  })  : _pagesProvider = currentMangaPagesProvider(
          contentDetails,
          mediaItems,
        ),
        _collectionItemProvider = collectionItemProvider(contentDetails);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_pagesProvider).when(
          data: (pages) => _renderReader(context, ref, pages),
          error: (error, stackTrace) => DisplayError(
            error: error,
            onRefresh: () => ref.refresh(_pagesProvider.future),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(
    BuildContext context,
    WidgetRef ref,
    List<ImageProvider> pages,
  ) {
    if (pages.isEmpty) {
      return DisplayError(
        error: AppLocalizations.of(context)!.mangaUnableToLoadPage,
        onRefresh: () => ref.refresh(_pagesProvider),
      );
    }

    final pageFeature =
        ref.read(collectionItemCurrentPositionProvider(contentDetails).future);

    return FutureBuilder(
      future: pageFeature,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return _MangaPagesReaderView(
          pages: pages,
          initialPage: snapshot.data!,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
          collectionItemProvider: _collectionItemProvider,
        );
      },
    );
  }
}

class _MangaPagesReaderView extends ConsumerStatefulWidget {
  final List<ImageProvider> pages;
  final int initialPage;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider collectionItemProvider;

  const _MangaPagesReaderView({
    required this.pages,
    required this.initialPage,
    required this.contentDetails,
    required this.mediaItems,
    required this.collectionItemProvider,
  });

  @override
  ConsumerState<_MangaPagesReaderView> createState() =>
      _MangaPagesReaderViewState();
}

class _MangaPagesReaderViewState extends ConsumerState<_MangaPagesReaderView> {
  final transformationController = TransformationController();
  final scrollOffsetController = ScrollOffsetController();
  late final ValueNotifier<int> page;

  @override
  void initState() {
    page = ValueNotifier(widget.initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

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
          onInvoke: (_) => _movePage(readerMode, -1),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => _movePage(readerMode, 1),
        ),
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) => Navigator.of(context).push(
            MangaReaderControlsRoute(
              contentDetails: widget.contentDetails,
              mediaItems: widget.mediaItems,
              onPageChanged: _jumpToPage,
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
        readerMode: readerMode,
        transformationController: transformationController,
        child: readerMode.scroll
            ? _ScrolledView(
                readerMode: readerMode,
                pages: widget.pages,
                initialPage: widget.initialPage,
                transformationController: transformationController,
                scrollOffsetController: scrollOffsetController,
                page: page,
                collectionItemProvider: widget.collectionItemProvider,
              )
            : _PagedView(
                readerMode: readerMode,
                pages: widget.pages,
                initialPage: widget.initialPage,
                transformationController: transformationController,
                pageListinable: page,
              ),
      ),
    );
  }

  void _jumpToPage(int value) {
    ref.read(widget.collectionItemProvider.notifier).setCurrentPosition(value);
    page.value = value;
  }

  void _movePage(MangaReaderMode readerMode, int inc) async {
    inc = readerMode.rtl ? -inc : inc;

    final contentProgress =
        (await ref.read(widget.collectionItemProvider.future));
    final pos = contentProgress.currentPosition;

    final newPos = pos + inc;
    final notifier = ref.read(widget.collectionItemProvider.notifier);

    if (newPos < 0) {
      if (contentProgress.currentItem > 0) {
        notifier.setCurrentItem(contentProgress.currentItem - 1);
      }
    } else if (newPos >= widget.pages.length) {
      if (contentProgress.currentItem < widget.mediaItems.length) {
        notifier.setCurrentItem(contentProgress.currentItem + 1);
      }
    } else {
      notifier.setCurrentPosition(newPos);
      page.value = newPos;
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
  final MangaReaderMode readerMode;
  final TransformationController transformationController;
  final Widget child;

  const _ReaderGestureDetector({
    required this.readerMode,
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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTapUp: (details) => _tapZones(details),
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

  bool _isInZone(
    int testZone,
    int zonesNum,
    Offset point,
  ) {
    final viewport = MediaQuery.sizeOf(context);
    final position =
        widget.readerMode.direction == Axis.horizontal ? point.dx : point.dy;
    final range = widget.readerMode.direction == Axis.horizontal
        ? viewport.width
        : viewport.height;

    final zoneSize = range / zonesNum.toDouble();
    final lowerBoundry = (testZone - 1) * zoneSize;
    final upperBoundry = testZone * zoneSize;

    return lowerBoundry <= position && position < upperBoundry;
  }

  void _tapZones(
    TapUpDetails details,
  ) {
    if (_isInZone(1, 3, details.globalPosition)) {
      Actions.invoke(context, const PrevPageIntent());
    } else if (_isInZone(3, 3, details.globalPosition)) {
      Actions.invoke(context, const NextPageIntent());
    }
  }

  void _toggleZoom() {
    final position = _lastTapDetails.globalPosition;
    final transfomationController = widget.transformationController;

    if (!_isInZone(2, 3, position)) {
      return;
    }

    if (!transfomationController.value.isIdentity()) {
      transfomationController.value = Matrix4.identity();
    } else {
      // For a 3x zoom
      transfomationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }
}

class _PagedView extends ConsumerStatefulWidget {
  final MangaReaderMode readerMode;
  final List<ImageProvider<Object>> pages;
  final int initialPage;
  final TransformationController transformationController;
  final ValueListenable<int> pageListinable;

  const _PagedView({
    required this.readerMode,
    required this.pages,
    required this.initialPage,
    required this.transformationController,
    required this.pageListinable,
  });

  @override
  ConsumerState<_PagedView> createState() => _PagedViewState();
}

class _PagedViewState extends ConsumerState<_PagedView> {
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialPage);
    widget.pageListinable.addListener(_onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListinable.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final pageNum = widget.pageListinable.value;
    final pages = widget.pages;

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

    _pageController?.animateToPage(
      pageNum,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      reverse: widget.readerMode.rtl,
      itemBuilder: (context, index) {
        return _SinglePageView(
          readerMode: widget.readerMode,
          page: widget.pages[index],
          transformationController: widget.transformationController,
        );
      },
      itemCount: widget.pages.length,
      scrollDirection: widget.readerMode.direction,
    );
  }
}

class _SinglePageView extends ConsumerWidget {
  final MangaReaderMode readerMode;
  final ImageProvider<Object> page;
  final TransformationController transformationController;

  const _SinglePageView({
    required this.readerMode,
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
          readerMode: readerMode,
          constraints: constraints,
          scale: scale,
          page: page,
        ),
      );
    });
  }
}

class _PageImage extends StatelessWidget {
  final MangaReaderMode readerMode;
  final BoxConstraints constraints;
  final MangaReaderScale scale;
  final ImageProvider<Object> page;

  const _PageImage({
    required this.readerMode,
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

            return MangaPagePlaceholder(
              readerMode: readerMode,
              constraints: constraints,
            );
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
  final MangaReaderMode readerMode;
  final List<ImageProvider<Object>> pages;
  final int initialPage;
  final TransformationController transformationController;
  final ScrollOffsetController scrollOffsetController;
  final ValueListenable<int> page;
  final CollectionItemProvider collectionItemProvider;

  const _ScrolledView({
    required this.readerMode,
    required this.pages,
    required this.initialPage,
    required this.transformationController,
    required this.scrollOffsetController,
    required this.page,
    required this.collectionItemProvider,
  });

  @override
  ConsumerState<_ScrolledView> createState() => _ScrolledViewState();
}

class _ScrolledViewState extends ConsumerState<_ScrolledView> {
  bool isScaling = false;
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    widget.transformationController.addListener(_onTransformationChange);
    widget.page.addListener(_onPageChanged);
    _itemPositionsListener.itemPositions.addListener(_onPositionChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_onTransformationChange);
    widget.page.removeListener(_onPageChanged);
    _itemPositionsListener.itemPositions.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    final firstItem = _itemPositionsListener.itemPositions.value.firstOrNull;
    final lastItem = _itemPositionsListener.itemPositions.value.lastOrNull;

    if (firstItem == null || lastItem == null) {
      return;
    }

    final pageIndex = (lastItem.index == widget.pages.length - 1 &&
            lastItem.itemTrailingEdge == 1.0)
        ? lastItem.index
        : firstItem.index;

    ref
        .watch(widget.collectionItemProvider.notifier)
        .setCurrentPosition(pageIndex);
  }

  void _onPageChanged() {
    _itemScrollController.jumpTo(
      index: widget.page.value,
      // duration: const Duration(milliseconds: 200),
    );
  }

  void _onTransformationChange() {
    final newIsScale = !widget.transformationController.value.isIdentity();
    if (newIsScale != isScaling) {
      if (mounted) {
        setState(() {
          isScaling = newIsScale;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return InteractiveViewer(
        transformationController: widget.transformationController,
        scaleEnabled: isScaling,
        panEnabled: isScaling,
        child: ScrollablePositionedList.separated(
          reverse: widget.readerMode.rtl,
          separatorBuilder: (context, index) =>
              const SizedBox.square(dimension: 8),
          scrollDirection: widget.readerMode.direction,
          scrollOffsetController: widget.scrollOffsetController,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          physics: isScaling
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: widget.pages.length,
          initialScrollIndex: widget.initialPage,
          itemBuilder: (context, index) => Image(
            image: widget.pages[index],
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return MangaPagePlaceholder(
                readerMode: widget.readerMode,
                constraints: constraints,
              );
            },
          ),
        ),
      );
    });
  }
}
