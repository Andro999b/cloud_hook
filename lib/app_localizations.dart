import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

String priorityLabel(
  BuildContext context,
  int priority,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (priority) {
    0 => localization.priorityLow,
    1 => localization.priorityNormal,
    _ => localization.priorityHight
  };
}

String mediaTypeLabel(
  BuildContext context,
  MediaType mediaType,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (mediaType) {
    MediaType.video => localization.mediaTypeVideo,
    MediaType.manga => localization.mediaTypeManga,
  };
}

String statusLabel(
  BuildContext context,
  MediaCollectionItemStatus status,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (status) {
    MediaCollectionItemStatus.inProgress => localization.statusLableWatchingNow,
    MediaCollectionItemStatus.complete => localization.statusLableComplete,
    MediaCollectionItemStatus.latter => localization.statusLableLatter,
    MediaCollectionItemStatus.onHold => localization.statusLableOnHold,
    _ => localization.addToCollection,
  };
}

String statusMenuItemLabel(
  BuildContext context,
  MediaCollectionItemStatus status,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (status) {
    MediaCollectionItemStatus.inProgress => localization.statusLableWatchingNow,
    MediaCollectionItemStatus.complete => localization.statusLableComplete,
    MediaCollectionItemStatus.latter => localization.statusLableLatter,
    MediaCollectionItemStatus.onHold => localization.statusLablePutOnHold,
    _ => localization.removeFromCollection,
  };
}

String contentTypeLabel(BuildContext context, ContentType type) {
  final localization = AppLocalizations.of(context)!;
  return switch (type) {
    ContentType.anime => localization.contentTypeAnime,
    ContentType.cartoon => localization.contentTypeCartoon,
    ContentType.movie => localization.contentTypeMovie,
    ContentType.series => localization.contentTypeSeries,
    ContentType.manga => localization.contentTypeManga,
  };
}

String mangaReaderScaleLabel(BuildContext context, MangaReaderScale mode) {
  final localization = AppLocalizations.of(context)!;
  return switch (mode) {
    MangaReaderScale.fit => localization.mangaReaderScaleFit,
    MangaReaderScale.fitHeight => localization.mangaReaderScaleFitHeight,
    MangaReaderScale.fitWidth => localization.mangaReaderScaleFitWidth,
  };
}

String mangaReaderBackgroundLabel(
    BuildContext context, MangaReaderBackground background) {
  final localization = AppLocalizations.of(context)!;
  return switch (background) {
    MangaReaderBackground.light => localization.mangaReaderBackgroundLight,
    MangaReaderBackground.dark => localization.mangaReaderBackgroundDark,
  };
}

String mangaReaderModeLabel(BuildContext context, MangaReaderMode mode) {
  final localization = AppLocalizations.of(context)!;
  return switch (mode) {
    MangaReaderMode.vertical => localization.mangaReaderModeVerical,
    MangaReaderMode.leftToRight => localization.mangaReaderModeLeftToRight,
    MangaReaderMode.rightToLeft => localization.mangaReaderModeRightToLeft,
    MangaReaderMode.vericalScroll => localization.mangaReaderModeVericalScroll,
    MangaReaderMode.hotizontalScroll =>
      localization.mangaReaderModeHorizontalScroll,
    MangaReaderMode.hotizontalRtlScroll =>
      localization.mangaReaderModeHorizontalRtlScroll,
  };
}
