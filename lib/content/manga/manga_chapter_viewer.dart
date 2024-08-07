import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content/manga/manga_content_view.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final pageProvider = currentMangaPageProvider(
      contentDetails,
      mediaItems,
    );

    return ref.watch(pageProvider).when(
          data: (data) => _renderReader(context, data),
          error: (error, stackTrace) => DisplayError(
            error: error,
            stackTrace: stackTrace,
            onRefresh: () => ref.refresh(pageProvider.future),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(BuildContext context, MangaChapterPages? chapterPages) {
    if (chapterPages == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.mangaUnableToLoadPage),
      );
    }

    // final haflLen = (chapterPages.pages.length / 2).ceil();
    precacheImage(chapterPages.pages[chapterPages.currentPage], context);
    for (int i = 1; i < 2; i++) {
      final r = chapterPages.currentPage + i;
      final l = chapterPages.currentPage - i;

      if (r < chapterPages.pages.length) {
        precacheImage(chapterPages.pages[r], context);
      }

      if (l >= 0) {
        precacheImage(chapterPages.pages[l], context);
      }
    }

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
          chapterPages: chapterPages,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _SinglePageViewer extends ConsumerWidget {
  final MangaChapterPages chapterPages;
  final ScrollController scrollController;

  const _SinglePageViewer({
    required this.chapterPages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = chapterPages.pages[chapterPages.currentPage];
    final imageMode = ref.watch(mangaReaderImageModeSettingsProvider);

    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return InteractiveViewer(
          scaleEnabled: imageMode == MangaReaderImageMode.fit,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Image(
              image: image,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.mangaPageLoading,
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
            ),
          ),
        );
      }),
      // ),
    );
  }
}
