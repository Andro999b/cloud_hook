import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

typedef PrioritySelectCallback = Function(int priority);

class CollectionItemPrioritySelector extends StatelessWidget {
  final MediaCollectionItem collectionItem;
  final PrioritySelectCallback onSelect;

  const CollectionItemPrioritySelector({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dropdown(
      anchorBuilder: (context, onPressed, child) => IconButton(
        onPressed: onPressed,
        icon: Icon(_priorityIcon(collectionItem.priority)),
        tooltip: AppLocalizations.of(context)!
            .priorityTooltip(priorityLabel(context, collectionItem.priority)),
      ),
      style: const MenuStyle(alignment: Alignment.topLeft),
      alignmentOffset: const Offset(0, -40),
      menuChildren: List.generate(3, (index) => index)
          .reversed
          .map(
            (index) => MenuItemButton(
              onPressed: () => onSelect(index),
              leadingIcon: Icon(_priorityIcon(index)),
              child: Text(priorityLabel(context, index)),
            ),
          )
          .toList(),
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
