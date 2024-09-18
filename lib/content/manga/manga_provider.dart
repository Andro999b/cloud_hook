import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_provider.g.dart';

class MangaChapterPages {
  final int currentPage;
  final List<ImageProvider> pages;

  MangaChapterPages({
    required this.currentPage,
    required this.pages,
  });
}

@riverpod
Future<List<MangaMediaItemSource>> currentMangaChapters(
  CurrentMangaChaptersRef ref,
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
Future<MangaMediaItemSource?> currentMangaChapter(
  CurrentMangaChapterRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final sources = await ref
      .watch(currentMangaChaptersProvider(contentDetails, mediaItems).future);
  final currentSource = await ref
      .watch(collectionItemCurrentSourceNameProvider(contentDetails).future);

  return currentSource == null
      ? sources.firstOrNull
      : sources.firstWhereOrNull((s) => s.description == currentSource);
}

@riverpod
Future<int> currentMangaChapterPageNum(
  CurrentMangaChapterPageNumRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  int currentPage = await ref
      .watch(collectionItemCurrentPositionProvider(contentDetails).future);

  final currentSource = await ref
      .watch(currentMangaChapterProvider(contentDetails, mediaItems).future);

  if (currentSource == null) {
    return 0;
  }

  if (currentPage > currentSource.pageNambers) {
    currentPage = 0;
  }

  return currentPage;
}

@riverpod
Future<List<ImageProvider<Object>>?> currentMangaChapterPages(
  CurrentMangaChapterPagesRef ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final currentSource = await ref
      .watch(currentMangaChapterProvider(contentDetails, mediaItems).future);

  if (currentSource == null) {
    return null;
  }

  final pages = await currentSource.allPages();

  return pages;
}
