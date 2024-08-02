import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/widgets/horizontal_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchResults extends HookWidget {
  final SearchState searchState;
  const SearchResults({super.key, required this.searchState});

  @override
  Widget build(BuildContext context) {
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
      // wait for first provider
      return const Center(child: CircularProgressIndicator());
    }

    // loading providers
    return ListView(
      children: [
        ...suppliersWithResult.map(
          (e) => _renderSupplierResults(context, e.key, e.value),
        ),
      ],
    );
  }

  Widget _renderSupplierResults(
      BuildContext context, String key, List<ContentInfo> value) {
    return HorizontalList(
      title: Text(
        key,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        final item = value[index];

        return ContentInfoCard(
          contentInfo: item,
          showSupplier: false,
        );
      },
      itemCount: value.length,
    );
  }
}
