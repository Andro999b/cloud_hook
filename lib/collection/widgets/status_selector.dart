import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:flutter/material.dart';

typedef StatusSelectCallBack = Function(MediaCollectionItemStatus status);

class CollectionItemStatusSelector extends StatelessWidget {
  late final MenuAnchorChildBuilder? anchorBuilder;
  late final Offset? alignmentOffset;
  final MediaCollectionItem collectionItem;
  final StatusSelectCallBack onSelect;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: anchorBuilder,
      alignmentOffset: alignmentOffset,
      menuChildren: _statusMenuItems(context),
      consumeOutsideTap: true,
    );
  }

  List<Widget> _statusMenuItems(BuildContext context) {
    return [
      ...MediaCollectionItemStatus.values
          .where((e) => e != MediaCollectionItemStatus.none)
          .map(
            (e) => MenuItemButton(
              onPressed: () => onSelect(e),
              child: Text(statusMenuItemLabel(context, e)),
            ),
          ),
      if (collectionItem.status != MediaCollectionItemStatus.none)
        MenuItemButton(
          onPressed: () => onSelect(MediaCollectionItemStatus.none),
          child: Text(
            statusMenuItemLabel(context, MediaCollectionItemStatus.none),
          ),
        )
    ];
  }

  CollectionItemStatusSelector.button({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  }) {
    anchorBuilder = (context, controller, child) => ElevatedButton.icon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(
            collectionItem.status == MediaCollectionItemStatus.none
                ? Icons.favorite_border
                : Icons.favorite,
          ),
          label: Text(statusLabel(context, collectionItem.status)),
        );
    alignmentOffset = null;
  }

  CollectionItemStatusSelector.iconButton({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  }) {
    anchorBuilder = (context, controller, child) => IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(
            collectionItem.status == MediaCollectionItemStatus.none
                ? Icons.favorite_border
                : Icons.favorite,
          ),
        );

    alignmentOffset = const Offset(0, -120);
  }
}
