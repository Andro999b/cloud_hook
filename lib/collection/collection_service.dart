import 'dart:async';

import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_repository.dart';

class CollectionService {
  final CollectionRepository repository;

  CollectionService({required this.repository});

  Stream<void> get changesStream => repository.changesStream;

  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id) {
    return repository.getCollectionItem(supplier, id);
  }

  FutureOr<MediaCollectionItem> save(MediaCollectionItem collectionItem) async {
    if (collectionItem.status == MediaCollectionItemStatus.none) {
      await repository.delete(collectionItem.supplier, collectionItem.id);
      collectionItem.internalId = null;
      return collectionItem;
    }

    collectionItem.lastSeen = DateTime.now();
    collectionItem.internalId = await repository.save(collectionItem);

    return collectionItem;
  }

  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
  }) {
    return repository.search(query: query, status: status);
  }
}
