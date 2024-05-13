import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final paddings = getPadding(context);
    final noResults =
        searchState.results.values.where((r) => r.isNotEmpty).isEmpty;

    if (!searchState.isLoading && noResults) {
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
      padding: EdgeInsets.symmetric(horizontal: paddings),
      children: [
        ...searchState.results.entries
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
      title: key,
      itemBuilder: (context, index) {
        final item = value[index];

        return ContentInfoCard(
          contentInfo: item,
          onTap: () {
            context.push("/content/${item.supplier}/${item.id}");
          },
        );
      },
      itemCount: value.length,
    );
  }
}
