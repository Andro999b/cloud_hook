import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_chapter_viewer.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_controls.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

class ShowUIIntent extends Intent {
  const ShowUIIntent();
}

class SwitchReaderImageMode extends Intent {
  final MangaReaderImageMode mode;
  const SwitchReaderImageMode(this.mode);
}

class MangaContentView extends HookConsumerWidget {
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
