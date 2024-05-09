import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/search/search_provider.dart';
import 'package:cloud_hook/utils/visual.dart';
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
      SearchState(isLoading: true) =>
        const Center(child: CircularProgressIndicator()),
      _ => _renderResults(context, searchState.results)
    };

    return Expanded(
      child: content,
    );
  }

  Widget _renderResults(
    BuildContext context,
    Map<String, List<ContentSearchResult>> resutls,
  ) {
    final paddings = getPadding(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: paddings),
      children: resutls.entries
          .map((e) => _renderSupplierResults(context, e.key, e.value))
          .toList(),
    );
  }

  Widget _renderEmptyResults(BuildContext context) {
    return const Center(child: Text("Пошук"));
  }

  Widget _renderSupplierResults(
      BuildContext context, String key, List<ContentSearchResult> value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            key,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            scrollDirection: Axis.horizontal,
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
          ),
        )
      ],
    );
  }
}
