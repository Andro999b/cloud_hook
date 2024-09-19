import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_view.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      mangaChapterScanProvider(contentDetails, mediaItems),
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
        MangaReaderView(
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MangaChapterProgressIndicator(contentDetails: contentDetails),
        ),
      ],
    );
  }
}
