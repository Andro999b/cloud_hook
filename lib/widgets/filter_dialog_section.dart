import 'package:flutter/material.dart';

class FilterDialogSection extends StatelessWidget {
  final Widget label;
  final int itemsCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback? onSelectAll;
  final VoidCallback? onUnselectAll;

  const FilterDialogSection({
    super.key,
    required this.label,
    required this.itemsCount,
    required this.itemBuilder,
    this.onSelectAll,
    this.onUnselectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            label,
            const Spacer(),
            if (onSelectAll != null)
              IconButton(
                onPressed: onSelectAll,
                icon: const Icon(Icons.check_circle_outline),
              ),
            if (onUnselectAll != null)
              IconButton(
                onPressed: onUnselectAll,
                icon: const Icon(Icons.cancel_outlined),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (int i = 0; i < itemsCount; i++) itemBuilder(context, i)
          ],
        )
      ],
    );
  }
}
