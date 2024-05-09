import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;

  const HorizontalList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverList.builder(
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        ],
      ),
    );
  }
}
