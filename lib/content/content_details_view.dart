import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content/manga/content_details_manga_actions.dart';
import 'package:cloud_hook/content/video/content_details_video_actions.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';

class ContentDetailsView extends ConsumerWidget {
  final ContentDetails contentDetails;

  const ContentDetailsView(this.contentDetails, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = _isCompactLayout(context);

    const imageRatio = .45;

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: mobile
                  ? constraints.maxWidth
                  : constraints.maxWidth * imageRatio,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(contentDetails.image),
                  fit: mobile ? BoxFit.fitWidth : BoxFit.fitHeight,
                  alignment: Alignment.topRight,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: _renderMainInfo(
              context,
              mobile
                  ? constraints.maxWidth
                  : constraints.maxWidth * (1 - imageRatio),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderMainInfo(BuildContext context, double width) {
    final paddings = getPadding(context);
    final mobile = _isCompactLayout(context);
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderTitle(context),
          if (mobile) SizedBox(height: size.height * .5),
          Container(
            padding: mobile
                ? EdgeInsets.symmetric(horizontal: paddings)
                : EdgeInsets.only(right: paddings),
            decoration: BoxDecoration(
              color: mobile ? theme.colorScheme.surface : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _renderContentActions(contentDetails),
                _MediaCollectionItemButtons(contentDetails),
                ..._renderAdditionalInfo(context),
                const SizedBox(height: 8),
                _renderDescription(context),
                if (contentDetails.similar.isNotEmpty)
                  ..._renderSimilar(context),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _renderTitle(BuildContext context) {
    final theme = Theme.of(context);
    final compact = _isCompactLayout(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SelectableText(
          contentDetails.title,
          style: theme.textTheme.headlineLarge?.copyWith(
            height: 1,
            color: compact ? Colors.white : null,
          ),
        ),
        if (contentDetails.originalTitle != null)
          SelectableText(
            contentDetails.originalTitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: compact ? Colors.white : null,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );

    if (compact) {
      return Container(
        padding: compact ? const EdgeInsets.symmetric(horizontal: 8) : null,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            if (isMobile(context)) const BackNavButton(color: Colors.white),
            Flexible(child: title)
          ],
        ),
      );
    }

    return title;
  }

  List<Widget> _renderAdditionalInfo(BuildContext context) {
    final paddings = getPadding(context);

    return [
      SizedBox(height: paddings),
      Wrap(
        children: [
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(contentDetails.supplier),
            ),
          ),
          ...contentDetails.additionalInfo.map(
            (e) => Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(e),
              ),
            ),
          ),
        ],
      )
    ];
  }

  Widget _renderDescription(BuildContext context) {
    final theme = Theme.of(context);

    if (AndroidTVDetector.isTV) {
      return Focus(
        child: Text(
          contentDetails.description,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

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
        children: contentDetails.similar
            .map(
              (e) => ContentInfoCard(
                contentInfo: e,
                showSupplier: false,
              ),
            )
            .toList(),
      )
    ];
  }

  Widget _renderContentActions(ContentDetails contentDetails) {
    return switch (contentDetails.mediaType) {
      MediaType.video => ContentDetailsVideoActions(contentDetails),
      MediaType.manga => ContentDetailsMangaActions(contentDetails),
    };
  }

  bool _isCompactLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 850;
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
              ref.read(provider.notifier).setPriority(priority);
            },
          )
      ],
    );
  }
}
