import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_model.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_provider.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings_provider.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchTopBar extends HookConsumerWidget {
  const SearchTopBar({super.key});

  void _search(WidgetRef ref, String query) {
    ref.read(searchProvider.notifier).search(query);
    ref.read(suggestionsProvider.notifier).addSuggestion(query);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useSearchController();

    useEffect(() {
      final query = ref.read(searchProvider).query ?? "";
      searchController.text = query;
      return null;
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: _renderSearchBar(
                    searchController,
                    context,
                    ref,
                  ),
                ),
              ),
              if (AndroidTVDetector.isTV)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _renderFilterSwitcher(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderSearchBar(
    SearchController searchController,
    BuildContext context,
    WidgetRef ref,
  ) {
    return SearchAnchor(
      isFullScreen: isMobile(context),
      searchController: searchController,
      viewOnChanged: (value) {
        ref.read(suggestionsProvider.notifier).suggest(value);
      },
      viewOnSubmitted: (value) {
        _search(ref, value);
        if (searchController.isOpen) {
          searchController.closeView(value);
        }
      },
      builder: (context, controller) {
        return SearchBar(
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.only(left: 16.0, right: 8.0),
          ),
          autoFocus: true,
          leading: const Icon(Icons.search),
          controller: controller,
          onTap: () {
            controller.openView();
          },
          onChanged: (value) {
            controller.openView();
          },
          onSubmitted: (value) {
            _search(ref, value);
          },
          trailing:
              AndroidTVDetector.isTV ? null : [_renderFilterSwitcher(context)],
        );
      },
      viewBuilder: (suggestions) => _TopSearchSuggestions(
        searchController: searchController,
        onSelect: (value) => _search(ref, value),
      ),
      suggestionsBuilder: (context, controller) => [],
    );
  }

  IconButton _renderFilterSwitcher(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const _FilterSelectorsDialog(),
        );
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class _FilterSelectorsDialog extends ConsumerWidget {
  const _FilterSelectorsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.only(left: isMobile(context) ? 0 : 80.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.contentType,
              style: theme.textTheme.headlineSmall,
            ),
            const _ContentTypeSelector(),
            Text(
              AppLocalizations.of(context)!.suppliers,
              style: theme.textTheme.headlineSmall,
            ),
            const _SuppliersSelector(),
          ],
        ),
      ),
    );
  }
}

class _ContentTypeSelector extends ConsumerWidget {
  const _ContentTypeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContentType = ref.watch(selectedContentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          ...ContentType.values.map(
            (type) => FilterChip(
              selected: selectedContentType.contains(type),
              label: Text(contentTypeLable(context, type)),
              onSelected: (value) {
                var notifier = ref.read(selectedContentProvider.notifier);
                if (value) {
                  notifier.select(type);
                } else {
                  notifier.unselect(type);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class _SuppliersSelector extends ConsumerWidget {
  const _SuppliersSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSuppliers = ref.watch(selectedSupplierProvider);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider);
    final selectedContentType = ref.watch(selectedContentProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          ...enabledSuppliers.map(
            (name) => _renderOption(
              selectedSuppliers,
              selectedContentType,
              name,
              ref,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderOption(
    Set<String> selectedSuppliers,
    Set<ContentType> selectedContentType,
    String name,
    WidgetRef ref,
  ) {
    final supplier = ContentSuppliers.instance.getSupplier(name)!;
    final enabled =
        supplier.supportedTypes.intersection(selectedContentType).isNotEmpty;

    return FilterChip(
      selected: selectedSuppliers.contains(name),
      label: Text(name),
      onSelected: enabled
          ? (value) {
              final notifier = ref.read(selectedSupplierProvider.notifier);
              if (value) {
                notifier.select(name);
              } else {
                notifier.unselect(name);
              }
            }
          : null,
    );
  }
}

class _TopSearchSuggestions extends HookConsumerWidget {
  const _TopSearchSuggestions(
      {required this.searchController, required this.onSelect});

  final SearchController searchController;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsValue = ref.watch(suggestionsProvider);

    return suggestionsValue.maybeWhen(
      data: (suggestions) {
        return ListView(
          children: suggestions
              .map((suggestion) => _renderSuggestion(suggestion, ref))
              .toList(),
        );
      },
      orElse: () => ListView(),
    );
  }

  Widget _renderSuggestion(SearchSuggestion suggestion, WidgetRef ref) {
    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 56.0),
          title: Text(suggestion.text),
          onTap: () {
            onSelect(suggestion.text);
            searchController.closeView(suggestion.text);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref
                    .read(suggestionsProvider.notifier)
                    .deleteSuggestion(suggestion);
              },
            ),
          ),
        )
      ],
    );
  }
}
