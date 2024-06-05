import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SearchState extends Equatable {
  final Map<String, List<ContentInfo>> results;
  final bool isLoading;
  final String? query;

  const SearchState({
    this.results = const {},
    required this.isLoading,
    this.query,
  });

  static const SearchState empty = SearchState(results: {}, isLoading: false);

  const SearchState.loading(
    String this.query,
  )   : isLoading = true,
        results = const {};

  SearchState copyWith({
    Map<String, List<ContentInfo>>? results,
    bool? isLoading,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [results, isLoading, query];
}
