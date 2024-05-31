import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_model.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_provider.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings_provider.dart';
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
    final showFilter = useState(false);

    useEffect(() {
      final query = ref.read(searchProvider).query ?? "";
      searchController.text = query;
      return null;
    });

    return Column(
      children: [
        _renderSearchBar(searchController, showFilter, context, ref),
        if (showFilter.value) const _FilterSelectors(),
      ],
    );
  }

  Widget _renderSearchBar(
    SearchController searchController,
    ValueNotifier<bool> showFilter,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SearchAnchor(
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
              padding: const MaterialStatePropertyAll<EdgeInsets>(
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
              trailing: [
                IconButton(
                  onPressed: () {
                    showFilter.value = !showFilter.value;
                  },
                  icon: const Icon(Icons.tune),
                )
              ],
            );
          },
          viewBuilder: (suggestions) => _TopSearchSuggestions(
            searchController: searchController,
            onSelect: (value) => _search(ref, value),
          ),
          suggestionsBuilder: (context, controller) => [],
        ), // do nothing
      ),
    );
  }
}

class _FilterSelectors extends ConsumerWidget {
  const _FilterSelectors();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(children: [
      _ContentTypeSelector(),
      _SuppliersSelector(),
    ]);
  }
}

class _ContentTypeSelector extends ConsumerWidget {
  const _ContentTypeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContentType = ref.watch(selectedContentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
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
