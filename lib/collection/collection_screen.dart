import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_top_bar.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
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
    final paddings = getPadding(context);

    return ListView(
      padding: EdgeInsets.only(left: paddings),
      children:
          groupsOrder.map((e) => CollectionHorizontalGroup(status: e)).toList(),
    );
  }
}

class CollectionHorizontalGroup extends ConsumerWidget {
  final MediaCollectionItemStatus status;

  const CollectionHorizontalGroup({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(
      collectionProvider.select((value) => value.valueOrNull?[status]),
    );

    if (group == null) {
      return const SizedBox.shrink();
    }

    return HorizontalList(
      title: statusLabel(context, status),
      itemBuilder: (context, index) {
        return _renderInfoCard(context, ref, group[index]);
      },
      itemCount: group.length,
    );
  }

  Widget _renderInfoCard(
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
                ref.read(collectionServiceProvider).save(
                      item.copyWith(
                        priority: priority,
                      ),
                    );
              },
            ),
            CollectionItemStatusSelector.iconButton(
              collectionItem: item,
              onSelect: (status) {
                ref.read(collectionServiceProvider).save(
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
