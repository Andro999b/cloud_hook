import 'dart:io';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/collection_top_bar.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/use_search_hint.dart';
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
    final focusNode = useFocusNode();
    final cornerVisible = useState(false);
    final desktop = isDesktopDevice();

    return ContentInfoCard(
      autofocus: autofocuse,
      contentInfo: item,
      onHover: desktop
          ? (value) {
              cornerVisible.value = value;
            }
          : null,
      onLongPress: desktop
          ? null
          : () {
              cornerVisible.value = !cornerVisible.value;
              focusNode.requestFocus();
            },
      corner: ValueListenableBuilder(
        valueListenable: cornerVisible,
        builder: (context, value, child) {
          return AnimatedOpacity(
            curve: Curves.easeInOut,
            opacity: value ? 1.0 : 0,
            duration: const Duration(milliseconds: 150),
            child: child,
          );
        },
        child: BackButtonListener(
          onBackButtonPressed: () async {
            focusNode.previousFocus();
            return true;
          },
          child: _CollectionListItemCorner(
            item: item,
            focusNode: focusNode,
          ),
        ),
      ),
    );
  }
}

class _CollectionListItemCorner extends ConsumerWidget {
  const _CollectionListItemCorner({
    required this.item,
    this.focusNode,
  });

  final MediaCollectionItem item;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(40)),
      child: FocusScope(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CollectionItemPrioritySelector(
              focusNode: focusNode,
              collectionItem: item,
              onSelect: (priority) {
                ref
                    .read(collectionServiceProvider)
                    .save(item.copyWith(priority: priority));
              },
            ),
            CollectionItemStatusSelector.iconButton(
              collectionItem: item,
              onSelect: (status) {
                ref
                    .read(collectionServiceProvider)
                    .save(item.copyWith(status: status));
              },
            ),
          ],
        ),
      ),
    );
  }
}
