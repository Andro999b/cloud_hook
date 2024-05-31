import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CollectionTopBar extends HookConsumerWidget {
  const CollectionTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(
      text: ref.read(collectionFilterQueryProvider),
    );
    final focusNode = useFocusNode();
    final showFilter = useState(false);

    return Column(
      children: [
        _renderSearhBar(controller, showFilter, focusNode, ref),
        if (showFilter.value) _StatusFilter(),
      ],
    );
  }

  Center _renderSearhBar(
    TextEditingController controller,
    ValueNotifier<bool> showFilter,
    FocusNode focusNode,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SearchBar(
          controller: controller,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.only(left: 16.0, right: 8.0),
          ),
          focusNode: focusNode,
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              onPressed: () {
                showFilter.value = !showFilter.value;
              },
              icon: const Icon(Icons.tune),
            ),
          ],
          onSubmitted: (value) {
            ref.read(collectionFilterQueryProvider.notifier).state = value;
            focusNode.requestFocus();
          },
        ),
      ),
    );
  }
}

class _StatusFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(collectionItemStatusFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...groupsOrder.map(
            (status) => FilterChip(
              selected: selected.contains(status),
              label: Text(statusLabel(context, status)),
              onSelected: (value) {
                final notifier =
                    ref.read(collectionItemStatusFilterProvider.notifier);
                if (value) {
                  notifier.select(status);
                } else {
                  notifier.unselect(status);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
