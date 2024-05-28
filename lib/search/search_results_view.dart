import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchResultsView extends HookConsumerWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    final content = switch (searchState) {
      SearchState.empty => _renderEmptyResults(context),
      _ => _renderResults(context, searchState)
    };

    return Expanded(
      child: content,
    );
  }

  Widget _renderResults(BuildContext context, SearchState searchState) {
    final suppliersWithResult =
        searchState.results.entries.where((r) => r.value.isNotEmpty);

    if (!searchState.isLoading && suppliersWithResult.isEmpty) {
      // no result
      return Center(
        child: Text(
          AppLocalizations.of(context)!.searchNoResults,
        ),
      );
    } else if (searchState.results.isEmpty) {
      // wait for firast provider
      return const Center(child: CircularProgressIndicator());
    }

    // loading providers
    return ListView(
      children: [
        ...suppliersWithResult
            .map((e) => _renderSupplierResults(context, e.key, e.value)),
        if (searchState.isLoading)
          const Center(child: CircularProgressIndicator())
      ],
    );
  }

  Widget _renderEmptyResults(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.search));
  }

  Widget _renderSupplierResults(
      BuildContext context, String key, List<ContentSearchResult> value) {
    return HorizontalList(
      title: Text(
        key,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        final item = value[index];

        return ContentInfoCard(
          contentInfo: item,
        );
      },
      itemCount: value.length,
    );
  }
}
