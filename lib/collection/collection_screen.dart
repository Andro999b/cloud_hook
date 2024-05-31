import 'dart:io';

import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/auth/auth_icon.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_top_bar.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:cloud_hook/widgets/use_search_hint.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 2,
      floatingActionButton: AuthIcon(),
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
    final collections = ref.watch(collectionProvider).valueOrNull;

    if (collections == null) {
      return const SizedBox.shrink();
    }

    if (collections.isEmpty) {
      return const UseSearchHint();
    }

    return ListView(
      children: groupsOrder.mapIndexed((groupIdx, e) {
        return CollectionHorizontalGroup(groupIdx: groupIdx, status: e);
      }).toList(),
    );
  }
}

class CollectionHorizontalGroup extends ConsumerWidget {
  final MediaCollectionItemStatus status;
  final int groupIdx;

  const CollectionHorizontalGroup({
    super.key,
    required this.groupIdx,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupItems = ref.watch(
      collectionProvider.select((value) => value.valueOrNull?[status]),
    );

    if (groupItems == null) {
      return const SizedBox.shrink();
    }

    return HorizontalList(
      title: Text(
        statusLabel(context, status),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        return CollectionHorizontalListItem(
          autofocuse: groupIdx == 0 && index == 0,
          item: groupItems[index],
        );
      },
      itemCount: groupItems.length,
    );
  }
}

class CollectionHorizontalListItem extends HookConsumerWidget {
  final MediaCollectionItem item;
  final bool autofocuse;

  const CollectionHorizontalListItem({
    super.key,
    required this.autofocuse,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = Platform.isWindows || Platform.isLinux;

    final cornerVisible = useState(false);

    return ContentInfoCard(
      autofocus: autofocuse,
      contentInfo: item,
      onHover: (value) {
        cornerVisible.value = value;
      },
      corner: isDesktop
          ? ValueListenableBuilder(
              valueListenable: cornerVisible,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: value ? 1.0 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: child,
                );
              },
              child: Container(
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
            )
          : null,
    );
  }
}
