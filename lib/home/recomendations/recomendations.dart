import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/home/recomendations/recomendations_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(suppliersSettingsProvider);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: enabledSuppliers
          .map((s) => (s, settings.getConfig(s)))
          .where((e) => e.$2.channels.isNotEmpty)
          .mapIndexed(
            (groupIdx, e) => [
              ...e.$2.channels.mapIndexed(
                (channelIdx, channel) => _RecomendationChannel(
                  channelIdx: channelIdx,
                  supplierName: e.$1,
                  channel: channel,
                ),
              ),
            ],
          )
          .expand((e) => e)
          .toList(),
    );
  }
}

class _RecomendationChannel extends HookConsumerWidget {
  final int channelIdx;
  final String supplierName;
  final String channel;

  const _RecomendationChannel({
    required this.channelIdx,
    required this.supplierName,
    required this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recomendationChannelProvider(supplierName, channel);
    final state = ref.watch(provider).valueOrNull;

    if (state == null || state.recomendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        var position = scrollController.position;
        if (position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(provider.notifier).loadNext();
        }
      }

      scrollController.addListener(onScroll);

      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    final list = HorizontalList(
      scrollController: scrollController,
      title: Text(
        channel,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        final item = state.recomendations[index];

        return ContentInfoCard(
          contentInfo: item,
          showSupplier: false,
        );
      },
      itemCount: state.recomendations.length,
    );

    if (channelIdx == 0) {
      final theme = Theme.of(context);
      final paddings = getPadding(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddings),
            child: Text(supplierName, style: theme.textTheme.titleLarge),
          ),
          list
        ],
      );
    }

    return list;
  }
}
