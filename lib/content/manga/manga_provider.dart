import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_provider.g.dart';

@riverpod
Future<List<MangaMediaItemSource>> mangaChapterScans(
  MangaChapterScansRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final currentItem =
      await ref.watch(collectionItemCurrentItemProvider(contentDetails).future);

  final currentChapter = mediaItems.elementAtOrNull(currentItem);

  if (currentChapter == null) {
    return const [];
  }

  return (await currentChapter.sources).cast();
}

@riverpod
Future<MangaMediaItemSource?> mangaChapterScan(
  MangaChapterScanRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final sources = await ref
      .watch(mangaChapterScansProvider(contentDetails, mediaItems).future);

  final currentSource = await ref
      .watch(collectionItemCurrentSourceNameProvider(contentDetails).future);

  return currentSource == null
      ? sources.firstOrNull
      : sources.firstWhereOrNull((s) => s.description == currentSource);
}

@riverpod
Future<MangaReaderChapter?> currentMangaReaderChapter(
  CurrentMangaReaderChapterRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final currentSource = await ref
      .watch(mangaChapterScanProvider(contentDetails, mediaItems).future);

  if (currentSource == null) {
    return null;
  }

  final initialPage = await ref
      .read(collectionItemCurrentPositionProvider(contentDetails).future);

  final pages = await currentSource.allPages();

  return MangaReaderChapter(pages: pages, initialPage: initialPage);
}
