import 'package:strumok/search/search_model.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:strumok/search/search_results.dart';
import 'package:strumok/search/search_top_bar/search_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    return Column(
      children: [
        const SearchTopBar(),
        if (searchState != SearchState.empty)
          Expanded(child: SearchResults(searchState: searchState))
      ],
    );
  }
}
