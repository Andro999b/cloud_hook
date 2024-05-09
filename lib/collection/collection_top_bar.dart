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
    final controller = useTextEditingController(
      text: ref.read(collectionFilterQueryProvider),
    );
    final focusNode = useFocusNode();
    final showFilter = useState(false);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: paddings),
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width > 896)
                const SizedBox(width: 56),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SearchBar(
                      controller: controller,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.only(left: 16.0, right: 8.0),
                      ),
                      autoFocus: true,
                      focusNode: focusNode,
                      leading: const Icon(Icons.search),
                      trailing: [
                        _renderTrailingIcon(ref, controller, showFilter)
                      ],
                      onSubmitted: (value) {
                        ref.read(collectionFilterQueryProvider.notifier).state =
                            value;
                        focusNode.requestFocus();
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: paddings),
                child: const AuthIcon(),
              )
            ],
          ),
        ),
        if (showFilter.value) _StatusFilter(),
      ],
    );
  }

  Widget _renderTrailingIcon(
    WidgetRef ref,
    TextEditingController controller,
    ValueNotifier<bool> showFilter,
  ) {
    return ValueListenableBuilder(
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
            icon: const Icon(Icons.filter_list),
          );
        }
      },
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
