import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_chapter_viewer.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class PrevPageIntent extends Intent {
  const PrevPageIntent();
}

class ScrollDownPageIntent extends Intent {
  const ScrollDownPageIntent();
}

class ScrollUpPageIntent extends Intent {
  const ScrollUpPageIntent();
}

class MangaContentView extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaContentView({
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

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): ScrollUpPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ScrollDownPageIntent(),
      },
      child: Actions(
        actions: {
          PrevPageIntent: CallbackAction<PrevPageIntent>(
            onInvoke: (_) => _movePage(-1, ref),
          ),
          NextPageIntent: CallbackAction<NextPageIntent>(
            onInvoke: (_) => _movePage(1, ref),
          )
        },
        child: Stack(
          children: [
            MangaChapterViewer(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
            ),
            Column(children: [
              _renderTopBar(context, ref),
              const Spacer(),
              MangaReaderBottomBar(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
              ),
            ])
          ],
        ),
      ),
      // ),
    );
  }

  Widget _renderTopBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(children: [
        const BackNavButton(),
        const Spacer(),
        _renderVolumesBotton(context, ref),
      ]),
    );
  }

  Widget _renderVolumesBotton(BuildContext context, WidgetRef ref) {
    return VolumesButton(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
      onSelect: (item) {
        final provider = collectionItemProvider(contentDetails);
        ref.read(provider.notifier).setCurrentItem(item.number);
      },
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
}
