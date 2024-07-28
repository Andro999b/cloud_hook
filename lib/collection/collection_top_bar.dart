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

    return Column(
      children: [
        _renderSearhBar(context, ref, controller, focusNode),
      ],
    );
  }

  Widget _renderSearhBar(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
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
                    : [_renderFilterSwitcher(context)],
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
              child: _renderFilterSwitcher(context),
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

  IconButton _renderFilterSwitcher(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context, builder: (context) => _StatusFilterDialog());
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class _StatusFilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.only(left: isMobile(context) ? 0 : 80.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.status,
              style: theme.textTheme.headlineSmall,
            ),
            const _StatusFilter(),
          ],
        ),
      ),
    );
  }
}

class _StatusFilter extends ConsumerWidget {
  const _StatusFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(collectionItemStatusFilterProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
