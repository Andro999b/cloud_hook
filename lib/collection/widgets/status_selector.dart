import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef StatusSelectCallBack = Function(MediaCollectionItemStatus status);
typedef AnchorChildBuilder = Function(
  BuildContext context,
  VoidCallback onPressed,
  Widget? child,
);

class CollectionItemStatusSelector extends StatefulWidget {
  late final AnchorChildBuilder? anchorBuilder;
  late final Offset? alignmentOffset;
  final MediaCollectionItem collectionItem;
  final StatusSelectCallBack onSelect;

  @override
  State<CollectionItemStatusSelector> createState() =>
      _CollectionItemStatusSelectorState();

  CollectionItemStatusSelector.button({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  }) {
    anchorBuilder = (context, onPressed, child) => ElevatedButton.icon(
          onPressed: onPressed,
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
    anchorBuilder = (context, onPressed, child) => IconButton(
          onPressed: onPressed,
          icon: Icon(
            collectionItem.status == MediaCollectionItemStatus.none
                ? Icons.favorite_border
                : Icons.favorite,
          ),
        );

    alignmentOffset = const Offset(0, -120);
  }
}

class _CollectionItemStatusSelectorState
    extends State<CollectionItemStatusSelector> {
  final _menuControler = MenuController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuControler,
      builder: widget.anchorBuilder == null
          ? null
          : (context, controller, child) {
              final anchorBuilder = widget.anchorBuilder!;
              return anchorBuilder(
                context,
                () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    _focusNode.requestFocus();
                    controller.open();
                  }
                },
                child,
              );
            },
      alignmentOffset: widget.alignmentOffset,
      menuChildren: [
        BackButtonListener(
          onBackButtonPressed: () async {
            _menuControler.close();
            return true;
          },
          child: FocusScope(
            child: Column(
              children: _statusMenuItems(context),
            ),
          ),
        )
      ],
      consumeOutsideTap: true,
    );
  }

  List<Widget> _statusMenuItems(BuildContext context) {
    return [
      ...MediaCollectionItemStatus.values
          .where(
            (e) =>
                e != MediaCollectionItemStatus.none &&
                e != widget.collectionItem.status,
          )
          .mapIndexed(
            (index, e) => MenuItemButton(
              focusNode: index == 0 ? _focusNode : null,
              onPressed: () => widget.onSelect(e),
              child: Text(statusMenuItemLabel(context, e)),
            ),
          ),
      if (widget.collectionItem.status != MediaCollectionItemStatus.none)
        MenuItemButton(
          onPressed: () => widget.onSelect(MediaCollectionItemStatus.none),
          child: Text(
            statusMenuItemLabel(context, MediaCollectionItemStatus.none),
          ),
        )
    ];
  }
}
