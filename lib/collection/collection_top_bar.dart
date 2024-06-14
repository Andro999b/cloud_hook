import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/auth/auth_icon.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_screen.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/visual.dart';
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
        _renderSearhBar(context, ref, controller, showFilter, focusNode),
        if (showFilter.value) _StatusFilter(),
      ],
    );
  }

  Widget _renderSearhBar(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
    ValueNotifier<bool> showFilter,
    FocusNode focusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: SearchBar(
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.only(left: 16.0, right: 8.0),
                ),
                focusNode: focusNode,
                leading: const Icon(Icons.search),
                trailing: AndroidTVDetector.isTV
                    ? null
                    : [_renderFilterSwitcher(showFilter)],
                onSubmitted: (value) {
                  ref.read(collectionFilterQueryProvider.notifier).state =
                      value;
                  focusNode.requestFocus();
                },
              ),
            ),
          ),
          if (AndroidTVDetector.isTV)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _renderFilterSwitcher(showFilter),
            ),
          if (isMobile(context))
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: AuthIcon(),
            )
        ],
      ),
    );
  }

  IconButton _renderFilterSwitcher(ValueNotifier<bool> showFilter) {
    return IconButton(
      onPressed: () {
        showFilter.value = !showFilter.value;
      },
      icon: const Icon(Icons.tune),
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
