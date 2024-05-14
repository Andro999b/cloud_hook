import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:cloud_hook/widgets/horizontal_list_card.dart';
import 'package:cloud_hook/widgets/use_search_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CollectionContinueView extends ConsumerWidget {
  const CollectionContinueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(collectionProvider).valueOrNull ?? {};

    List<MediaCollectionItem>? items;
    String? title;

    if (groups.containsKey(MediaCollectionItemStatus.inProgress)) {
      items = groups[MediaCollectionItemStatus.inProgress]?.toList();
      title = AppLocalizations.of(context)!.collectionContiue;
    } else if (groups.containsKey(MediaCollectionItemStatus.latter)) {
      items = groups[MediaCollectionItemStatus.latter]?.toList();
      title = AppLocalizations.of(context)!.collectionBegin;
    }

    if (items == null) {
      return _renderEmptyCollection(context);
    }

    return HorizontalList(
      title: title!,
      itemBuilder: (context, index) {
        final item = items![index];

        return ContentInfoCard(
          contentInfo: item,
          onTap: () {
            context.push("/content/${item.supplier}/${item.id}");
          },
        );
      },
      itemCount: items.length,
    );
  }

  Widget _renderEmptyCollection(BuildContext context) {
    return HorizontalList(
      title: AppLocalizations.of(context)!.collectionBegin,
      itemBuilder: (context, index) => HorizontalListCard(
        onTap: () {
          context.go("/search");
        },
        child: const UseSearchHint(),
      ),
      itemCount: 1,
    );
  }
}
