import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef SelectCallback = void Function(ContentMediaItem item);

class MediaItemsListRoute<T> extends PopupRoute<T> {
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;

  MediaItemsListRoute({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    required this.mediaItems,
    this.contentProgress,
    required this.onSelect,
  });

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dissmiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: Align(
        alignment: Alignment.centerRight,
        child: AppTheme(
          child: SafeArea(
            child: _MediaItemsListView(
              mediaItems: mediaItems,
              contentProgress: contentProgress,
              onSelect: (item) {
                Navigator.of(context).pop();
                onSelect(item);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaItemsListView extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;

  const _MediaItemsListView({
    required this.mediaItems,
    required this.contentProgress,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final mobile = isMobile(context);

    const radius = Radius.circular(10);

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: mobileWidth * 0.7,
      height: size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.only(
          topLeft: mobile ? Radius.zero : radius,
          bottomLeft: mobile ? Radius.zero : radius,
        ),
      ),
      child: Material(
        child: Column(
          children: [
            _renderTitle(context),
            Expanded(
              child: _MediaItemsList(
                mediaItems: mediaItems,
                contentProgress: contentProgress,
                onSelect: onSelect,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.episodesList,
          style: theme.textTheme.headlineMedium,
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        )
      ],
    );
  }
}

class _MediaItemsList extends HookWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;

  const _MediaItemsList({
    required this.mediaItems,
    required this.contentProgress,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final groups = useMemoized(
      () => mediaItems.groupListsBy((element) => element.section ?? ""),
    );

    if (groups.length == 1) {
      return _MediaItemsListSection(
        list: groups.values.first,
        contentProgress: contentProgress,
        onSelect: onSelect,
      );
    }

    return DefaultTabController(
      initialIndex: _currentSectionIndex(groups),
      length: groups.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabs: groups.keys.map((e) => Tab(text: e)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: groups.values
                  .map(
                    (e) => _MediaItemsListSection(
                      list: e,
                      contentProgress: contentProgress,
                      onSelect: onSelect,
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  int _currentSectionIndex(Map<String, dynamic> groups) {
    if (contentProgress == null) {
      return 0;
    }

    final currentItem = mediaItems[contentProgress!.currentItem];
    return groups.keys.toList().indexOf(currentItem.section!);
  }
}

class _MediaItemsListSection extends HookWidget {
  final List<ContentMediaItem> list;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;

  const _MediaItemsListSection({
    required this.list,
    required this.contentProgress,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final index = useMemoized(() {
      final currentItem = contentProgress?.currentItem ?? 0;
      final index = list.indexWhere((element) => element.number == currentItem);
      return index > 0 ? index - 1 : 0;
    });

    return ScrollablePositionedList.builder(
      initialScrollIndex: index,
      itemBuilder: (context, index) {
        final item = list[index];
        final image = item.image;
        final title = item.title;
        final progress = contentProgress?.positions[index]?.progress ?? 0;

        return _MediaItemsListItem(
          title: title,
          image: image,
          selected: item.number == contentProgress?.currentItem,
          progress: progress,
          onTap: () {
            onSelect(item);
          },
        );
      },
      itemCount: list.length,
    );
  }
}

class _MediaItemsListItem extends StatelessWidget {
  final String title;
  final String? image;
  final bool selected;
  final double progress;
  final VoidCallback onTap;

  const _MediaItemsListItem({
    required this.title,
    this.image,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: selected
          ? theme.colorScheme.onInverseSurface
          : theme.colorScheme.surfaceVariant,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 96,
              height: 72,
              decoration: BoxDecoration(
                image: image != null
                    ? DecorationImage(
                        image: FastCachedImageProvider(image!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color:
                    image == null ? theme.colorScheme.onPrimaryContainer : null,
              ),
              child: selected
                  ? const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(title),
                subtitle: LinearProgressIndicator(
                  value: progress,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
