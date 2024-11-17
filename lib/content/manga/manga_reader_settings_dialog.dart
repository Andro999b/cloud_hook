import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
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
              MangaTranslationSelector(
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
        Dropdown.button(
          lable: mangaReaderBackgroundLabel(context, currentBackground),
          menuChildrenBulder: (focusNode) => MangaReaderBackground.values
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(mangaReaderBackgroundSettingsProvider.notifier)
                        .select(value);
                  },
                  child: Text(mangaReaderBackgroundLabel(context, value)),
                ),
              )
              .toList(),
        ),
      ],
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
            .watch(mangaChapterScansProvider(
              contentDetails,
              mediaItems,
            ))
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
        Dropdown.button(
          lable: currentSource ?? sources.first.description,
          menuChildrenBulder: (focusNode) => sources
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(collectionItemProvider(contentDetails).notifier)
                        .setCurrentSource(value.description);
                  },
                  child: Text(value.description),
                ),
              )
              .toList(),
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
        Dropdown.button(
          lable: mangaReaderModeLabel(context, currentMode),
          menuChildrenBulder: (focusNode) => MangaReaderMode.values
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(mangaReaderModeSettingsProvider.notifier)
                        .select(value);
                  },
                  child: Text(mangaReaderModeLabel(context, value)),
                ),
              )
              .toList(),
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
        Dropdown.button(
          lable: mangaReaderScaleLabel(context, currentScale),
          menuChildrenBulder: (focusNode) => MangaReaderScale.values
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(mangaReaderScaleSettingsProvider.notifier)
                        .select(value);
                  },
                  child: Text(mangaReaderScaleLabel(context, value)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
