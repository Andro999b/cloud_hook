import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class MediaCollectionItemConsumerWidger extends ConsumerWidget {
  final ContentDetails contentDetails;

  const MediaCollectionItemConsumerWidger({
    super.key,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProgress = ref.watch(collectionItemProvider(contentDetails));

    return currentProgress.maybeWhen(
      data: (data) => render(context, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem collectionItem,
  );
}
