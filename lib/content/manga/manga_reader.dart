import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_controls.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'intents.dart';

class MangaReader extends HookConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReader({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<MangaMediaItemSource?>>(
      currentMangaChapterProvider(contentDetails, mediaItems),
      (previous, next) {
        final chapter = next.valueOrNull;
        if (chapter != null) {
          ref
              .read(collectionItemProvider(contentDetails).notifier)
              .setCurrentLength(chapter.pageNambers);
        }
      },
    );

    final scrollController = useScrollController();

    return FocusableActionDetector(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): ScrollUpPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ScrollDownPageIntent(),
        SingleActivator(LogicalKeyboardKey.select): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.digit1):
            SwitchReaderImageMode(MangaReaderImageMode.original),
        SingleActivator(LogicalKeyboardKey.digit2):
            SwitchReaderImageMode(MangaReaderImageMode.fit),
        SingleActivator(LogicalKeyboardKey.digit3):
            SwitchReaderImageMode(MangaReaderImageMode.fitHeight),
        SingleActivator(LogicalKeyboardKey.digit4):
            SwitchReaderImageMode(MangaReaderImageMode.fitWidth),
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) => _movePage(-1, ref),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => _movePage(1, ref),
        ),
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) => Navigator.of(context).push(
            MangaReaderControlsRoute(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
            ),
          ),
        ),
        SwitchReaderImageMode: CallbackAction<SwitchReaderImageMode>(
          onInvoke: (intent) => _swithReaderImageMode(intent.mode, ref),
        ),
        ScrollUpPageIntent: CallbackAction<ScrollUpPageIntent>(
          onInvoke: (_) => _scrollTo(scrollController, -100),
        ),
        ScrollDownPageIntent: CallbackAction<ScrollDownPageIntent>(
          onInvoke: (_) => _scrollTo(scrollController, 100),
        ),
      },
      autofocus: true,
      child: MangaChapterViewer(
        contentDetails: contentDetails,
        mediaItems: mediaItems,
        scrollController: scrollController,
      ),
    );
  }

  void _movePage(int inc, WidgetRef ref) async {
    final chapter = await ref
        .read(currentMangaChapterProvider(contentDetails, mediaItems).future);

    final provider = collectionItemProvider(contentDetails);
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
        if (contentProgress.currentItem < mediaItems.length) {
          notifier.setCurrentItem(contentProgress.currentItem + 1);
        }
      } else {
        notifier.setCurrentPosition(newPos, chapter.pageNambers);
      }
    }
  }

  void _swithReaderImageMode(MangaReaderImageMode mode, WidgetRef ref) {
    ref.read(mangaReaderImageModeSettingsProvider.notifier).select(mode);
  }

  void _scrollTo(ScrollController controller, int inc) {
    double newPos = controller.offset + inc;
    controller.jumpTo(newPos);
  }
}

class MangaChapterViewer extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ScrollController scrollController;

  const MangaChapterViewer({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageProvider = currentMangaChapterPagesProvider(
      contentDetails,
      mediaItems,
    );

    return ref.watch(pageProvider).when(
          data: (pages) => _renderReader(context, pages),
          error: (error, stackTrace) => DisplayError(
            error: error,
            stackTrace: stackTrace,
            onRefresh: () => ref.refresh(pageProvider.future),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(
      BuildContext context, List<ImageProvider<Object>> pages) {
    if (pages.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.mangaUnableToLoadPage),
      );
    }

    // precacheImage(chapterPages.pages[chapterPages.currentPage], context);
    // for (int i = 1; i < 2; i++) {
    //   final r = chapterPages.currentPage + i;
    //   final l = chapterPages.currentPage - i;

    //   if (r < chapterPages.pages.length) {
    //     precacheImage(chapterPages.pages[r], context);
    //   }

    //   if (l >= 0) {
    //     precacheImage(chapterPages.pages[l], context);
    //   }
    // }

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GestureDetector(
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          Actions.invoke(context, const PrevPageIntent());
        } else if (details.globalPosition.dx < (screenWidth / 3) * 2) {
          Actions.invoke(context, const ShowUIIntent());
        } else {
          Actions.invoke(context, const NextPageIntent());
        }
      },
      child: Container(
        width: size.width,
        height: size.height,
        color: theme.colorScheme.surface,
        child: _SinglePageViewer(
          pages: pages,
          pageNumProvider:
              currentMangaChapterPageNumProvider(contentDetails, mediaItems),
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _SinglePageViewer extends ConsumerWidget {
  final List<ImapeProvisder<Object>> pages;
  final CurrentMangaChapterPageNumProvider pageNumProvider;
  final ScrollController scrollController;

  const _SinglePageViewer({
    required this.pages,
    required this.pageNumProvider,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final image = chapterPages.pages[chapterPages.currentPage];
    // final imageMode = ref.watch(mangaReaderImageModeSettingsProvider);

    // return Center(
    //   child: LayoutBuilder(
    //       builder: (BuildContext context, BoxConstraints constraints) {
    //     return InteractiveViewer(
    //       scaleEnabled: imageMode == MangaReaderImageMode.fit,
    //       child: SingleChildScrollView(
    //         controller: scrollController,
    //         child: MangaPageImage(
    //           image: image,
    //           imageMode: imageMode,
    //           constraints: constraints,
    //         ),
    //       ),
    //     );
    //   }),
    //   // ),
    // );
    return Text("");
  }
}

class _ScrollPagesViewer extends ConsumerWidget {
  final List<ImageProvider<Object>> pages;
  final CurrentMangaChapterPageNumProvider pageNumProvider;
  final ScrollController scrollController;

  const _ScrollPagesViewer({
    required this.pages,
    required this.pageNumProvider,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageMode = ref.watch(mangaReaderImageModeSettingsProvider);

    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return InteractiveViewer(
          scaleEnabled: !isDesktopDevice(),
          child: ScrollablePositionedList.builder(
            itemCount: chapterPages.pages.length,
            initialScrollIndex: chapterPages.currentPage,
            itemBuilder: (context, index) {
              final page = chapterPages.pages[index];

              return MangaPageImage(
                image: page,
                imageMode: imageMode,
                constraints: constraints,
              );
            },
          ),
        );
      }),
      // ),
    );
  }
}

class MangaPageImage extends StatelessWidget {
  const MangaPageImage({
    super.key,
    required this.image,
    required this.imageMode,
    required this.constraints,
  });

  final ImageProvider<Object> image;
  final MangaReaderImageMode imageMode;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Image(
      image: image,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return SizedBox(
          height: size.height,
          width: size.width,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.mangaPageLoading,
            ),
          ),
        );
      },
      fit: switch (imageMode) {
        MangaReaderImageMode.fitHeight => BoxFit.fitHeight,
        MangaReaderImageMode.fitWidth => BoxFit.fitWidth,
        _ => BoxFit.contain
      },
      width: switch (imageMode) {
        MangaReaderImageMode.fitWidth ||
        MangaReaderImageMode.fit =>
          constraints.maxWidth,
        _ => null
      },
      height: switch (imageMode) {
        MangaReaderImageMode.fitHeight ||
        MangaReaderImageMode.fit =>
          constraints.maxHeight,
        _ => null
      },
    );
  }
}
