import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  final String title;
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;

  const HorizontalList({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: paddings),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 8, left: paddings),
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        )
      ],
    );
  }
}
