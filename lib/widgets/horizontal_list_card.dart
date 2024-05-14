import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';

const maxImageWidth = 320.0;

class HorizontalListCard extends StatelessWidget {
  final GestureTapCallback onTap;
  final Decoration? decoration;
  final Widget? child;

  const HorizontalListCard(
      {super.key, required this.onTap, this.decoration, this.child});

  @override
  Widget build(BuildContext context) {
    var imageWidth =
        isMobile(context) ? MediaQuery.of(context).size.width * .45 : 200.0;

    if (imageWidth > maxImageWidth) {
      imageWidth = maxImageWidth;
    }

    final imageHeight = imageWidth * 1.5;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: imageHeight,
            maxWidth: imageWidth,
          ),
          decoration: decoration,
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}
