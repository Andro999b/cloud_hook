import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/widgets/horizontal_list_card.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

const maxImageWidth = 320.0;

class ContentInfoCard extends StatelessWidget {
  const ContentInfoCard({
    super.key,
    required this.contentInfo,
    this.corner,
    required this.onTap,
  });

  final Widget? corner;
  final ContentInfo contentInfo;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HorizontalListCard(
      onTap: onTap,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FastCachedImageProvider(contentInfo.image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: corner != null
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: corner,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
            ),
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              title: Text(
                contentInfo.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(
                contentInfo.subtitle ?? "",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
