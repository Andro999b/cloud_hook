import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:flutter/material.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

String priorityLabel(BuildContext context, int priority) {
  return switch (priority) {
    0 => AppLocalizations.of(context)!.priorityLow,
    1 => AppLocalizations.of(context)!.priorityNormal,
    _ => AppLocalizations.of(context)!.priorityHight
  };
}

String statusLabel(BuildContext context, MediaCollectionItemStatus status) {
  return switch (status) {
    MediaCollectionItemStatus.inProgress =>
      AppLocalizations.of(context)!.statusLableWatchingNow,
    MediaCollectionItemStatus.complete =>
      AppLocalizations.of(context)!.statusLableComplete,
    MediaCollectionItemStatus.latter =>
      AppLocalizations.of(context)!.statusLableLatter,
    MediaCollectionItemStatus.onHold =>
      AppLocalizations.of(context)!.statusLableOnHold,
    _ => AppLocalizations.of(context)!.addToCollection,
  };
}

String statusMenuItemLabel(
    BuildContext context, MediaCollectionItemStatus status) {
  return switch (status) {
    MediaCollectionItemStatus.inProgress =>
      AppLocalizations.of(context)!.statusLableWatchingNow,
    MediaCollectionItemStatus.complete =>
      AppLocalizations.of(context)!.statusLableComplete,
    MediaCollectionItemStatus.latter =>
      AppLocalizations.of(context)!.statusLableLatter,
    MediaCollectionItemStatus.onHold =>
      AppLocalizations.of(context)!.statusLablePutOnHold,
    _ => AppLocalizations.of(context)!.removeFromCollection,
  };
}
