import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';

class ContentDetailsView extends ConsumerWidget {
  final ContentDetails contentDetails;

  const ContentDetailsView(this.contentDetails, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final mobile = isMobile(context);

    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FastCachedImageProvider(contentDetails.image),
          alignment: mobile ? Alignment.topCenter : Alignment.centerRight,
          fit: mobile ? BoxFit.fitWidth : BoxFit.fitHeight,
        ),
      ),
      child: SingleChildScrollView(
        child: _renderMainInfo(context),
      ),
    );
  }

  double _calcMaxWidth(Size size, bool mobile) {
    var maxWidth = mobile ? size.width : size.width - size.height * .85;

    if (maxWidth < mobileWidth) {
      maxWidth = mobileWidth;
    }

    return maxWidth;
  }

  Widget _renderMainInfo(BuildContext context) {
    final paddings = getPadding(context);
    final mobile = isMobile(context);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    final bottomPart = Container(
      padding: mobile ? EdgeInsets.symmetric(horizontal: paddings) : null,
      decoration: mobile ? BoxDecoration(color: colorScheme.surface) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _ContentWatchButtons(contentDetails),
          _MediaCollectionItemButtons(contentDetails),
          if (contentDetails.additionalInfo.isNotEmpty)
            ..._renderAdditionalInfo(context),
          SizedBox(height: paddings),
          _renderDescription(context),
          if (contentDetails.similar.isNotEmpty) ..._renderSimilar(context),
          const SizedBox(height: 8),
        ],
      ),
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(
          minWidth: mobileWidth,
          maxWidth: _calcMaxWidth(size, mobile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _renderTitile(context),
            if (mobile) SizedBox(height: size.height * .40),
            bottomPart
          ],
        ),
      ),
    );
  }

  Widget _renderTitile(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = isMobile(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SelectableText(
          contentDetails.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            height: 1,
            color: mobile ? Colors.white : null,
          ),
        ),
        if (contentDetails.originalTitle != null)
          SelectableText(
            contentDetails.originalTitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mobile ? Colors.white : null,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );

    if (mobile) {
      return Container(
        padding: mobile ? const EdgeInsets.symmetric(horizontal: 8) : null,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            const BackNavButton(color: Colors.white),
            Flexible(child: title)
          ],
        ),
      );
    }

    return Focus(child: title);
  }

  List<Widget> _renderAdditionalInfo(BuildContext context) {
    final paddings = getPadding(context);

    return [
      SizedBox(height: paddings),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: contentDetails.additionalInfo
            .map((e) => Chip(label: Text(e)))
            .toList(),
      )
    ];
  }

  Widget _renderDescription(BuildContext context) {
    final theme = Theme.of(context);

    return ReadMoreText(
      contentDetails.description,
      trimMode: TrimMode.Line,
      trimLines: 4,
      trimCollapsedText: AppLocalizations.of(context)!.readMore,
      trimExpandedText: AppLocalizations.of(context)!.readLess,
      style: theme.textTheme.bodyLarge?.copyWith(inherit: true),
    );
  }

  Iterable<Widget> _renderSimilar(BuildContext context) {
    final theme = Theme.of(context);
    final paddings = getPadding(context);

    return [
      SizedBox(height: paddings),
      Text(
        AppLocalizations.of(context)!.recomendations,
        style: theme.textTheme.headlineSmall,
      ),
      SizedBox(height: paddings),
      Wrap(
        runSpacing: 6,
        children: contentDetails.similar
            .map(
              (e) => ContentInfoCard(
                contentInfo: e,
                onTap: () {
                  context.push("/content/${e.supplier}/${e.id}");
                },
              ),
            )
            .toList(),
      )
    ];
  }
}

class _ContentWatchButtons extends HookWidget {
  final ContentDetails contentDetails;

  const _ContentWatchButtons(this.contentDetails);

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);

    final mediaItemsFuture = useMemoized(
      () => Future.value(contentDetails.mediaItems),
    );
    final snapshot = useFuture(mediaItemsFuture);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      var theme = Theme.of(context);
      return Text(
        snapshot.error.toString(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    final mediaItems = snapshot.data!.toList();

    if (mediaItems.isEmpty) {
      return const SizedBox(height: 40);
    }

    final showList = mediaItems.firstOrNull?.title.isNotEmpty ?? false;

    return Row(
      children: [
        _renderWatchButton(context),
        SizedBox(width: paddings),
        if (showList)
          _ContentPlaylistButton(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
          )
      ],
    );
  }

  FilledButton _renderWatchButton(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        context.push("/video/${contentDetails.supplier}/${contentDetails.id}");
      },
      icon: const Icon(Icons.play_arrow_outlined),
      label: Text(AppLocalizations.of(context)!.watchButton),
    );
  }
}

class _ContentPlaylistButton extends ConsumerWidget {
  _ContentPlaylistButton({
    required this.contentDetails,
    required this.mediaItems,
  }) : provider = collectionItemProvider(contentDetails);

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentItem = ref.watch(provider);

    return contentItem.maybeWhen(
      data: (data) => _renderButton(context, ref, data),
      orElse: () => _renderButton(context, ref, null),
    );
  }

  IconButton _renderButton(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem? collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        navigator.push(
          MediaItemsListRoute(
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: (item) {
              ref.read(provider.notifier).setCurrentItem(item.number);
              context.push(
                  "/video/${contentDetails.supplier}/${contentDetails.id}");
            },
          ),
        );
      },
      icon: const Icon(Icons.list),
      tooltip: AppLocalizations.of(context)!.episodesList,
    );
  }
}

class _MediaCollectionItemButtons extends ConsumerWidget {
  _MediaCollectionItemButtons(ContentDetails contentDetails)
      : provider = collectionItemProvider(contentDetails);

  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ref.watch(provider).maybeWhen(
            data: (data) => _render(context, ref, data),
            orElse: () => const SizedBox(height: 40),
          ),
    );
  }

  Widget _render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem data,
  ) {
    final paddings = getPadding(context);

    return Row(
      children: [
        const SizedBox(height: 40),
        CollectionItemStatusSelector.button(
          collectionItem: data,
          onSelect: (status) {
            ref.read(provider.notifier).setStatus(status);
          },
        ),
        SizedBox(width: paddings),
        if (data.status != MediaCollectionItemStatus.none)
          CollectionItemPrioritySelector(
            collectionItem: data,
            onSelect: (priority) {
              ref.read(provider.notifier).setPriorit(priority);
            },
          )
      ],
    );
  }
}
