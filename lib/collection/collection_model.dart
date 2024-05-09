import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class CollectionState {
  final String? query;
  final Map<MediaCollectionItemStatus, List<MediaCollectionItem>> groups;
  final Set<MediaCollectionItemStatus> status;

  const CollectionState({
    this.query,
    required this.groups,
    required this.status,
  });

  static const empty = CollectionState(groups: {}, status: {});

  CollectionState copyWith({
    String? query,
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>? groups,
    Set<MediaCollectionItemStatus>? status,
  }) {
    return CollectionState(
      query: query ?? this.query,
      groups: groups ?? this.groups,
      status: status ?? this.status,
    );
  }
}
