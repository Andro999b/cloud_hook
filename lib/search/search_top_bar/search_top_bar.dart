import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_model.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchTopBar extends HookConsumerWidget {
  const SearchTopBar({super.key});

  void _search(WidgetRef ref, String query) {
    final selecterSuppliers = ref.read(selectedSupplierProvider);
    final contentTypes = ref.read(selectedContentProvider);
    ref
        .read(searchProvider.notifier)
        .search(query, selecterSuppliers, contentTypes);
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
        Container(
          padding: const EdgeInsets.all(8),
          child: SearchAnchor(
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
                    EdgeInsets.only(left: 16.0, right: 8.0)),
                autoFocus: true,
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    onPressed: () {
                      showFilter.value = !showFilter.value;
                    },
                    icon: const Icon(Icons.filter_list),
                  )
                ],
                controller: controller,
                onTap: () {
                  controller.openView();
                },
                onChanged: (value) {
                  controller.openView();
                },
                onSubmitted: (value) {
                  _search(ref, value);
                  // controller.clear();
                },
              );
            },
            viewBuilder: (suggestions) => _TopSearchSuggestions(
              searchController: searchController,
              onSelect: (value) => _search(ref, value),
            ),
            suggestionsBuilder: (context, controller) => [],
          ), // do nothing
        ),
        if (showFilter.value) const _FilterSelectors(),
      ],
    );
  }
}

class _FilterSelectors extends ConsumerWidget {
  const _FilterSelectors();

  Widget _renderSuppliers(WidgetRef ref) {
    final selectedSuppliers = ref.watch(selectedSupplierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...ContentSuppliers.instance.suppliersName.map(
            (name) => FilterChip(
              selected: selectedSuppliers.contains(name),
              label: Text(name),
              onSelected: (value) {
                final notifier = ref.read(selectedSupplierProvider.notifier);
                if (value) {
                  notifier.select(name);
                } else {
                  notifier.unselect(name);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderContentType(WidgetRef ref) {
    final selectedContentType = ref.watch(selectedContentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 6,
        runSpacing: 6,
        children: [
          ...ContentType.values.map(
            (type) => FilterChip(
              selected: selectedContentType.contains(type),
              label: Text(type.name),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [_renderSuppliers(ref), _renderContentType(ref)]);
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
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0, right: 8.0),
      title: Text(suggestion.text),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          ref.read(suggestionsProvider.notifier).deleteSuggestion(suggestion);
        },
      ),
      onTap: () {
        onSelect(suggestion.text);
        searchController.closeView(suggestion.text);
      },
    );
  }
}
