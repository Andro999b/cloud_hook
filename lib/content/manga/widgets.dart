import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:cloud_hook/settings/theme/brightnes_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@immutable
class VolumesButton extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final SelectCallback? onSelect;

  const VolumesButton({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    this.onSelect,
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
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: onSelect ??
                (item) {
                  ref.read(provider.notifier).setCurrentItem(item.number);
                  context.push(
                      "/${contentDetails.mediaType.name}/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
                },
          ),
        );
      },
      icon: const Icon(Icons.list),
      tooltip: AppLocalizations.of(context)!.episodesList,
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

    final imageMode = ref.watch(mangaReaderImageModeSettingsProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Тема", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            const BrightnesSwitcher(),
            const SizedBox(height: 8),
            MangaTranslationSelector(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
            ),
            const SizedBox(height: 8),
            Text("Розміщеня зображення", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text("Оригинільне зображеня"),
                  selected: imageMode == MangaReaderImageMode.original,
                  onSelected: (value) {
                    ref
                        .read(mangaReaderImageModeSettingsProvider.notifier)
                        .select(MangaReaderImageMode.original);
                  },
                ),
                ChoiceChip(
                  label: const Text("Розтягнути"),
                  selected: imageMode == MangaReaderImageMode.fit,
                  onSelected: (value) {
                    ref
                        .read(mangaReaderImageModeSettingsProvider.notifier)
                        .select(MangaReaderImageMode.fit);
                  },
                ),
                ChoiceChip(
                  label: const Text("Розтягнути по ширині"),
                  selected: imageMode == MangaReaderImageMode.fitWidth,
                  onSelected: (value) {
                    ref
                        .read(mangaReaderImageModeSettingsProvider.notifier)
                        .select(MangaReaderImageMode.fitWidth);
                  },
                ),
                ChoiceChip(
                  label: const Text("Розтягнути по висоті"),
                  selected: imageMode == MangaReaderImageMode.fitHeight,
                  onSelected: (value) {
                    ref
                        .read(mangaReaderImageModeSettingsProvider.notifier)
                        .select(MangaReaderImageMode.fitHeight);
                  },
                ),
              ],
            )
          ],
        ),
      ),
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
        Text("Переклад", style: theme.textTheme.headlineSmall),
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
