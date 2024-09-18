import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumesButton extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final SelectCallback? onSelect;
  final Color? color;
  final bool autofocus;

  const VolumesButton({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    this.onSelect,
    this.color,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = collectionItemProvider(contentDetails);
    final contentItem = ref.watch(provider);

    return contentItem.maybeWhen(
      data: (data) => _renderButton(context, provider, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  IconButton _renderButton(
    BuildContext context,
    CollectionItemProvider provider,
    WidgetRef ref,
    MediaCollectionItem? collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MediaItemsListRoute(
            title: AppLocalizations.of(context)!.mangaChapter,
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: onSelect ??
                (item) {
                  ref.read(provider.notifier).setCurrentItem(item.number);
                  context.push(
                      "/${contentDetails.mediaType.name}/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
                },
            itemBuilder: mangaItemBuilder,
          ),
        );
      },
      icon: const Icon(Icons.list),
      color: color,
      tooltip: AppLocalizations.of(context)!.mangaChapter,
      autofocus: autofocus,
    );
  }
}

Widget mangaItemBuilder(
  ContentMediaItem item,
  ContentProgress? contentProgress,
  SelectCallback onSelect,
) {
  final progress = contentProgress?.positions[item.number]?.progress ?? 0;

  return MangaItemsListItem(
    item: item,
    selected: item.number == contentProgress?.currentItem,
    progress: progress,
    onTap: () {
      onSelect(item);
    },
  );
}

class MangaItemsListItem extends StatelessWidget {
  final ContentMediaItem item;
  final bool selected;
  final double progress;
  final VoidCallback onTap;

  const MangaItemsListItem({
    super.key,
    required this.item,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.title;
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(color: theme.colorScheme.surfaceContainerHigh),
          ),
        ),
        ListTile(
          onTap: onTap,
          autofocus: selected,
          mouseCursor: SystemMouseCursors.click,
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: selected ? const Icon(Icons.menu_book) : null,
        ),
      ],
    );
  }
}

class MangaBackground extends ConsumerWidget {
  const MangaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    final currentBackground = ref.watch(mangaReaderBackgroundSettingsProvider);

    return Container(
      width: size.width,
      height: size.height,
      color: switch (currentBackground) {
        MangaReaderBackground.light => Colors.white,
        MangaReaderBackground.dark => Colors.black,
      },
    );
  }
}

class MangaChapterProgressIndicator extends ConsumerWidget {
  final ContentDetails contentDetails;

  const MangaChapterProgressIndicator({
    super.key,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref
        .watch(collectionItemCurrentMediaItemPositionProvider(contentDetails))
        .valueOrNull;

    if (pos == null || pos.length == 0) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(value: pos.progress);
  }
}
