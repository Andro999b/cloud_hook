import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_provider.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: FocusScope(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      (mode) => _renderImageMode(
                          context, ref, currentImageMode, mode),
                    )
                    .toList(),
              )
            ],
          ),
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
      label: Text(mangaReaderImageModeLabel(context, mode)),
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
        .watch(collectionItemCurrentSourceNameProvider(contentDetails))
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
