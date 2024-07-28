import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/widgets/horizontal_list_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContentInfoCard extends StatelessWidget {
  final bool autofocus;
  final bool showSupplier;

  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Widget? corner;
  final ContentInfo contentInfo;
  final GestureTapCallback? onTap;

  const ContentInfoCard({
    super.key,
    required this.contentInfo,
    this.corner,
    this.onTap,
    this.onHover,
    this.onLongPress,
    this.autofocus = false,
    this.showSupplier = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HorizontalListCard(
      autofocus: autofocus,
      onTap: onTap ??
          () {
            context.push(
                "/content/${contentInfo.supplier}/${Uri.encodeComponent(contentInfo.id)}");
          },
      onHover: onHover,
      onLongPress: onLongPress,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(contentInfo.image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      corner: corner,
      badge: showSupplier
          ? Badge(
              label: Text(contentInfo.supplier),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              backgroundColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.onPrimary,
            )
          : null,
      child: Column(
        children: [
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                stops: [.5, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              title: Text(
                contentInfo.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, inherit: true),
                maxLines: 2,
              ),
              subtitle: contentInfo.secondaryTitle == null
                  ? null
                  : Text(
                      contentInfo.secondaryTitle!,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white, inherit: true),
                      maxLines: 2,
                    ),
            ),
          )
        ],
      ),
    );
  }
}
