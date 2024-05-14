import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/home/recomendations/recomendations_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Recommendations extends ConsumerWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recomendationsAsync = ref.watch(recomendationsProvider);
    return recomendationsAsync.when(
      data: (data) => _renderRecomendations(context, data),
      error: (error, stackTrace) => DisplayError(
        error: error,
        stackTrace: stackTrace,
      ),
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _renderRecomendations(
    BuildContext context,
    Map<String, SupplierChannels> data,
  ) {
    final theme = Theme.of(context);
    final paddings = getPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries
          .where((e) => e.value.isNotEmpty)
          .map(
            (e) => [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddings),
                child: Text(e.key, style: theme.textTheme.titleLarge),
              ),
              ...e.value.entries.map(
                (channel) => _renderChannel(channel.key, channel.value),
              ),
            ],
          )
          .expand((e) => e)
          .toList(),
    );
  }

  HorizontalList _renderChannel(String channelName, List<ContentInfo> items) {
    return HorizontalList(
      title: channelName,
      itemBuilder: (context, index) {
        final item = items[index];

        return ContentInfoCard(
          contentInfo: item,
          onTap: () {
            context.push("/content/${item.supplier}/${item.id}");
          },
        );
      },
      itemCount: items.length,
    );
  }
}
