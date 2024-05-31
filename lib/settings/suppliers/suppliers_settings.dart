import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuppliersSettingsSection extends StatelessWidget {
  const SuppliersSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = getPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsSuppliers,
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: padding),
        _RecomendationsSettingsList()
      ],
    );
  }
}

class _RecomendationsSettingsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersOrder = ref.watch(
        suppliersSettingsProvider.select((value) => value.suppliersOrder));

    return Container(
      constraints: const BoxConstraints.tightFor(width: 800),
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        proxyDecorator: _proxyDecorator,
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) {
          ref
              .read(suppliersSettingsProvider.notifier)
              .reorder(oldIndex, newIndex);
        },
        children: suppliersOrder
            .mapIndexed(
              (index, supplier) => Container(
                key: ValueKey(supplier),
                child: _RecomendationsSettingsItem(
                  supplierName: supplier,
                  index: index,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
      child: child,
    );
  }
}

class _RecomendationsSettingsItem extends ConsumerWidget {
  final int index;
  final String supplierName;

  const _RecomendationsSettingsItem({
    required this.index,
    required this.supplierName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = getPadding(context);
    final config = ref.watch(
      suppliersSettingsProvider.select(
        (value) => value.getConfig(supplierName),
      ),
    );

    final supplier = ContentSuppliers.instance.getSupplier(supplierName)!;

    return Card.outlined(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderTtitle(context, ref, supplier, config),
            const SizedBox(height: 8),
            _renderChannels(context, ref, supplier, config),
          ],
        ),
      ),
    );
  }

  Row _renderTtitle(
    BuildContext context,
    WidgetRef ref,
    ContentSupplier supplier,
    SuppliersConfig config,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // enable checkbox
        Checkbox(
          value: config.enabled,
          onChanged: (value) {
            if (value == true) {
              ref
                  .read(suppliersSettingsProvider.notifier)
                  .enableSupplier(supplierName);
            } else {
              ref
                  .read(suppliersSettingsProvider.notifier)
                  .disableSupplier(supplierName);
            }
          },
        ),
        const SizedBox(width: 8),
        // supplier name
        Text(
          supplierName,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        // supplier languages
        ...supplier.supportedLanguages.map(
          (e) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Badge(
              backgroundColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.onPrimary,
              label: Text(e.code),
            ),
          ),
        ),
        const Spacer(),
        // drag handle
        ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
      ],
    );
  }

  Widget _renderChannels(
    BuildContext context,
    WidgetRef ref,
    ContentSupplier supplier,
    SuppliersConfig config,
  ) {
    final channels = supplier.channels;

    return channels.isEmpty
        ? const SizedBox.shrink()
        : Wrap(
            spacing: 6,
            runSpacing: 6,
            children: channels
                .map(
                  (channel) => ChoiceChip(
                    selected: config.channels.contains(channel),
                    label: Text(channel),
                    onSelected: (value) {
                      if (value) {
                        ref
                            .read(suppliersSettingsProvider.notifier)
                            .enableChannel(supplierName, channel);
                      } else {
                        ref
                            .read(suppliersSettingsProvider.notifier)
                            .disableChannel(supplierName, channel);
                      }
                    },
                  ),
                )
                .toList(),
          );
  }
}
