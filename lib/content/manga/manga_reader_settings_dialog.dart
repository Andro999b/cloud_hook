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
    final currentMode = ref.watch(mangaReaderModeSettingsProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: FocusScope(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _MangaReaderBackgroundSelector(),
              const SizedBox(height: 8),
              _MangaTranslationSelector(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
              ),
              const SizedBox(height: 8),
              const _MangaReaderModeSelector(),
              const SizedBox(height: 8),
              if (!currentMode.scroll) const _ImageScaleSelector()
            ],
          ),
        ),
      ),
    );
  }
}

class _MangaReaderBackgroundSelector extends ConsumerWidget {
  const _MangaReaderBackgroundSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentBackground = ref.watch(mangaReaderBackgroundSettingsProvider);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.mangaReaderBackground,
          style: theme.textTheme.headlineSmall,
        ),
        DropdownMenu(
          initialSelection: currentBackground,
          onSelected: (value) {
            ref
                .read(mangaReaderBackgroundSettingsProvider.notifier)
                .select(value!);
          },
          dropdownMenuEntries: MangaReaderBackground.values.map(
            (value) {
              return DropdownMenuEntry(
                value: value,
                label: mangaReaderBackgroundLabel(context, value),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _MangaTranslationSelector extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const _MangaTranslationSelector({
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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.mangaTranslation,
          style: theme.textTheme.headlineSmall,
        ),
        DropdownMenu(
          initialSelection: currentSource,
          onSelected: (value) {
            ref
                .read(collectionItemProvider(contentDetails).notifier)
                .setCurrentSource(value);
          },
          dropdownMenuEntries: sources.map(
            (value) {
              return DropdownMenuEntry(
                value: value.description,
                label: value.description,
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _MangaReaderModeSelector extends ConsumerWidget {
  const _MangaReaderModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(mangaReaderModeSettingsProvider);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.mangaReaderMode,
          style: theme.textTheme.headlineSmall,
        ),
        DropdownMenu(
          initialSelection: currentMode,
          onSelected: (value) {
            ref.read(mangaReaderModeSettingsProvider.notifier).select(value!);
          },
          dropdownMenuEntries: MangaReaderMode.values.map(
            (value) {
              return DropdownMenuEntry(
                value: value,
                label: mangaReaderModeLabel(context, value),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _ImageScaleSelector extends ConsumerWidget {
  const _ImageScaleSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentScale = ref.watch(mangaReaderScaleSettingsProvider);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.mangaReaderScale,
          style: theme.textTheme.headlineSmall,
        ),
        DropdownMenu(
          initialSelection: currentScale,
          onSelected: (value) {
            ref.read(mangaReaderScaleSettingsProvider.notifier).select(value!);
          },
          dropdownMenuEntries: MangaReaderScale.values.map(
            (value) {
              return DropdownMenuEntry(
                value: value,
                label: mangaReaderScaleLabel(context, value),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
