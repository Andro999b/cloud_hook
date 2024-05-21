import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

typedef PrioritySelectCallback = Function(int priority);

class CollectionItemPrioritySelector extends StatefulWidget {
  final MediaCollectionItem collectionItem;
  final PrioritySelectCallback onSelect;

  const CollectionItemPrioritySelector({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  });

  @override
  State<CollectionItemPrioritySelector> createState() =>
      _CollectionItemPrioritySelectorState();
}

class _CollectionItemPrioritySelectorState
    extends State<CollectionItemPrioritySelector> {
  final _menuController = MenuController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      builder: (context, controller, child) => IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            _focusNode.requestFocus();
            controller.open();
          }
        },
        icon: Icon(_priorityIcon(widget.collectionItem.priority)),
        tooltip: AppLocalizations.of(context)!.priorityTooltip(
            priorityLabel(context, widget.collectionItem.priority)),
      ),
      style: const MenuStyle(alignment: Alignment.topLeft),
      alignmentOffset: const Offset(0, -40),
      menuChildren: [
        BackButtonListener(
          onBackButtonPressed: () async {
            _menuController.close();
            return true;
          },
          child: FocusScope(
            child: Column(
              children: List.generate(3, (index) => index)
                  .reversed
                  .map(
                    (index) => MenuItemButton(
                      focusNode: index == widget.collectionItem.priority
                          ? _focusNode
                          : null,
                      onPressed: () => widget.onSelect(index),
                      leadingIcon: Icon(_priorityIcon(index)),
                      child: Text(priorityLabel(context, index)),
                    ),
                  )
                  .toList(),
            ),
          ),
        )
      ],
      consumeOutsideTap: true,
    );
  }

  IconData _priorityIcon(int priority) {
    return switch (priority) {
      0 => Symbols.stat_1,
      1 => Symbols.stat_2,
      _ => Symbols.stat_3
    };
  }
}
