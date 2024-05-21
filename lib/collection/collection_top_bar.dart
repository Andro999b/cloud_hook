import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/auth/auth_icon.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/collection/collection_screen.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CollectionTopBar extends HookConsumerWidget {
  const CollectionTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paddings = getPadding(context);
    final mobile = isMobile(context);
    final controller = useTextEditingController(
      text: ref.read(collectionFilterQueryProvider),
    );
    final focusNode = useFocusNode();
    final showFilter = useState(false);

    return Column(
      children: [
        Row(
          children: [
            mobile
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: AuthIcon(),
                  )
                : const SizedBox(width: 48),
            Expanded(
              child: _renderSearhBar(ref, controller, focusNode),
            ),
            _renderSettingsIcon(ref, controller, showFilter)
          ],
        ),
        if (showFilter.value) _StatusFilter(),
      ],
    );
  }

  Center _renderSearhBar(
    WidgetRef ref,
    TextEditingController controller,
    FocusNode focusNode,
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
          onSubmitted: (value) {
            ref.read(collectionFilterQueryProvider.notifier).state = value;
            focusNode.requestFocus();
          },
        ),
      ),
    );
  }

  Widget _renderSettingsIcon(
    WidgetRef ref,
    TextEditingController controller,
    ValueNotifier<bool> showFilter,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          if (value.text.isNotEmpty) {
            return IconButton(
              onPressed: () {
                ref.read(collectionFilterQueryProvider.notifier).state = "";
                controller.clear();
              },
              icon: const Icon(Icons.close),
            );
          } else {
            return IconButton(
              onPressed: () {
                showFilter.value = !showFilter.value;
              },
              icon: const Icon(Icons.tune),
            );
          }
        },
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
