import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_top_bar.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 2,
      child: Column(
        children: [
          CollectionTopBar(),
          Expanded(child: CollectionHorizontalView()),
        ],
      ),
    );
  }
}

const groupsOrder = [
  MediaCollectionItemStatus.inProgress,
  MediaCollectionItemStatus.latter,
  MediaCollectionItemStatus.onHold,
  MediaCollectionItemStatus.complete,
];

class CollectionHorizontalView extends ConsumerWidget {
  const CollectionHorizontalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCollection = ref.watch(collectionProvider);

    return asyncCollection.when(
      data: (data) => _renderGroups(context, ref, data),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
    );
  }

  _renderGroups(
    BuildContext context,
    WidgetRef ref,
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>> groups,
  ) {
    final paddings = getPadding(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: paddings),
      children: groupsOrder
          .where((e) => groups.containsKey(e))
          .map(
            (e) => _renderGroup(context, ref, e, groups[e]!),
          )
          .toList(),
    );
  }

  Widget _renderGroup(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItemStatus status,
    List<MediaCollectionItem> items,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            statusLabel(context, status),
            style: theme.textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _renderInfoCard(context, ref, items[index]);
            },
            itemCount: items.length,
          ),
        )
      ],
    );
  }

  ContentInfoCard _renderInfoCard(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem item,
  ) {
    final theme = Theme.of(context);
    return ContentInfoCard(
      contentInfo: item,
      onTap: () {
        context.push("/content/${item.supplier}/${item.id}");
      },
      corner: Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CollectionItemPrioritySelector(
              collectionItem: item,
              onSelect: (priority) {
                ref.read(collectionItemRepositoryProvider).save(
                      item.copyWith(
                        priority: priority,
                      ),
                    );
              },
            ),
            CollectionItemStatusSelector.iconButton(
              collectionItem: item,
              onSelect: (status) {
                ref.read(collectionItemRepositoryProvider).save(
                      item.copyWith(
                        status: status,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
