import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_controls.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    return Stack(
      children: [
        const MangaBackground(),
        MangaByPageReader(
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        ),
      ],
    );
  }
}

class MangaByPageReader extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaByPageReader({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageProvider = currentMangaChapterPagesProvider(
      contentDetails,
      mediaItems,
    );

    return ref.watch(pageProvider).when(
          data: (pages) => _renderReader(context, ref, pages ?? const []),
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
    List<ImageProvider<Object>> pages,
  ) {
    if (pages.isEmpty == true) {
      return Center(
        child: Text(AppLocalizations.of(context)!.mangaUnableToLoadPage),
      );
    }

    final scrollController = ScrollController();

    final size = MediaQuery.of(context).size;

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
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTapUp: (details) {
              final screenWidth = size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                Actions.invoke(context, const PrevPageIntent());
              } else if (details.globalPosition.dx < (screenWidth / 3) * 2) {
                Actions.invoke(context, const ShowUIIntent());
              } else {
                Actions.invoke(context, const NextPageIntent());
              }
            },
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: _SinglePageView(
                pages: pages,
                pageNumProvider: currentMangaChapterPageNumProvider(
                  contentDetails,
                  mediaItems,
                ),
                scrollController: scrollController,
              ),
            ),
          );
        },
      ),
    );
  }

  void _movePage(int inc, WidgetRef ref) async {
    final chapter = await ref.read(
      currentMangaChapterProvider(contentDetails, mediaItems).future,
    );

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

class _SinglePageView extends ConsumerWidget {
  final List<ImageProvider<Object>> pages;
  final CurrentMangaChapterPageNumProvider pageNumProvider;
  final ScrollController scrollController;

  const _SinglePageView({
    required this.pages,
    required this.pageNumProvider,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageMode = ref.watch(mangaReaderImageModeSettingsProvider);
    return ref.watch(pageNumProvider).when(
          data: (pageNum) => _renderPage(context, ref, pageNum, imageMode),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        );
  }

  Widget _renderPage(
    BuildContext context,
    WidgetRef ref,
    int pageNum,
    MangaReaderImageMode imageMode,
  ) {
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

    final image = pages[pageNum];

    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return InteractiveViewer(
          scaleEnabled: imageMode == MangaReaderImageMode.fit,
          child: SingleChildScrollView(
            controller: scrollController,
            child: MangaPageImage(
              image: image,
              imageMode: imageMode,
              constraints: constraints,
            ),
          ),
        );
      }),
    );
  }
}
