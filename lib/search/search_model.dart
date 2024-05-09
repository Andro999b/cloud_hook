import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';

@immutable
class SearchState {
  final Map<String, List<ContentSearchResult>> results;
  final bool isLoading;
  final String? query;

  const SearchState({
    required this.results,
    required this.isLoading,
    this.query,
  });

  static const SearchState empty = SearchState(results: {}, isLoading: false);

  const SearchState.loading(
    String this.query,
  )   : isLoading = true,
        results = const {};

  SearchState addResults(
      MapEntry<String, Iterable<ContentSearchResult>> providerResults) {
    final Map<String, Iterable<ContentSearchResult>> newResults =
        Map.from(results);
    newResults[providerResults.key] = providerResults.value;
    return SearchState(
      results: Map.unmodifiable(newResults),
      isLoading: isLoading,
      query: query,
    );
  }

  SearchState loadingDone() => SearchState(
        results: results,
        isLoading: false,
        query: query,
      );
}
