import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/settings/theme/brightnes_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MangaReaderBottomBar extends MediaCollectionItemConsumerWidger {
  final List<ContentMediaItem> mediaItems;

  const MangaReaderBottomBar({
    super.key,
    required super.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  ) {
    final theme = Theme.of(context);
    final pos = collectionItem.currentMediaItemPosition;

    final curPage = pos.position + 1;
    final pageNumbers = pos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "$curPage / $pageNumbers",
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => MangaReaderSettingsDialog(
                      contentDetails: contentDetails,
                      mediaItems: mediaItems,
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              )
            ],
          ),
        ),
        if (pageNumbers > 0) LinearProgressIndicator(value: pos.progress)
      ],
    );
  }
}

class VolumesButton extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final SelectCallback? onSelect;
  final bool autofocus;

  const VolumesButton({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    this.onSelect,
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
      tooltip: AppLocalizations.of(context)!.mangaChapter,
      autofocus: autofocus,
    );
  }
}

class MangaReaderSettingsDialog extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderSettingsDialog({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final currentImageMode = ref.watch(mangaReaderImageModeSettingsProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsTheme,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const BrightnesSwitcher(),
            const SizedBox(height: 8),
            MangaTranslationSelector(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.mangaImageReaderMode,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: MangaReaderImageMode.values
                  .map(
                    (mode) =>
                        _renderImageMode(context, ref, currentImageMode, mode),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderImageMode(
    BuildContext context,
    WidgetRef ref,
    MangaReaderImageMode currentMode,
    MangaReaderImageMode mode,
  ) {
    return ChoiceChip(
      label: Text(mangaReaderImageModeLable(context, mode)),
      selected: currentMode == mode,
      onSelected: (value) {
        ref.read(mangaReaderImageModeSettingsProvider.notifier).select(mode);
      },
    );
  }
}

class MangaTranslationSelector extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaTranslationSelector({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSource = ref
        .watch(collectionItemCurrentSourceProvider(contentDetails))
        .valueOrNull;

    return ref
            .watch(currentMangaChaptersProvider(contentDetails, mediaItems))
            .whenOrNull(
              data: (value) =>
                  _renderSources(context, ref, value, currentSource),
            ) ??
        const SizedBox.shrink();
  }

  Widget _renderSources(
    BuildContext context,
    WidgetRef ref,
    List<MangaMediaItemSource> sources,
    String? currentSource,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mangaTranslation,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: sources
              .map(
                (s) => ChoiceChip(
                  label: Text(s.description),
                  selected: s.description == currentSource,
                  onSelected: (value) {
                    if (value) {
                      ref
                          .read(collectionItemProvider(contentDetails).notifier)
                          .setCurrentSource(s.description);
                    }
                  },
                ),
              )
              .toList(),
        )
      ],
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
            child: Container(color: theme.colorScheme.surfaceVariant),
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
