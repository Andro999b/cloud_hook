import 'dart:async';

import 'package:cloud_hook/app_database.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:isar/isar.dart';

part 'collection_repository.g.dart';

@collection
@Name("MediaCollectionItem")
class IsarMediaCollectionItem {
  IsarMediaCollectionItem({
    required this.id,
    required this.supplier,
    required this.title,
    required this.image,
    required this.currentItem,
    required this.currentSource,
    required this.positions,
    required this.status,
    required this.priority,
    this.lastSeen,
    this.isarId,
  });

  Id? isarId;

  final String id;
  @Index(
    name: "supplierId",
    composite: [CompositeIndex('id')],
    unique: true,
  )
  final String supplier;
  final String title;
  final String image;
  final int currentItem;
  final int currentSource;
  final List<IsarMediaItemPosition> positions;

  @Enumerated(EnumType.ordinal)
  MediaCollectionItemStatus status;

  final int priority;
  DateTime? lastSeen;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get fts => Isar.splitWords(title);

  factory IsarMediaCollectionItem.fromMediaCollectionItem(
    MediaCollectionItem collectionItem,
  ) {
    return IsarMediaCollectionItem(
      id: collectionItem.id,
      supplier: collectionItem.supplier,
      title: collectionItem.title,
      image: collectionItem.image,
      currentItem: collectionItem.currentItem,
      currentSource: collectionItem.currentSource,
      positions: collectionItem.positions.entries
          .map(
            (e) => IsarMediaItemPosition()
              ..number = e.key
              ..position = e.value.position
              ..length = e.value.length,
          )
          .toList(),
      status: collectionItem.status,
      priority: collectionItem.priority,
      lastSeen: collectionItem.lastSeen,
      isarId: collectionItem.internalId,
    );
  }

  MediaCollectionItem toMediaCollectionItem() {
    return MediaCollectionItem(
      id: id,
      supplier: supplier,
      title: title,
      image: image,
      currentItem: currentItem,
      currentSource: currentSource,
      positions: Map.fromEntries(
        positions.map(
          (e) => MapEntry(
            e.number,
            MediaItemPosition(
              position: e.position,
              length: e.length,
            ),
          ),
        ),
      ),
      status: status,
      priority: priority,
      lastSeen: lastSeen,
      internalId: isarId,
    );
  }
}

@embedded
@Name("IsarMediaCollectionItemPosition")
class IsarMediaItemPosition {
  int number = 0;
  int position = 0;
  int length = 0;
}

abstract class CollectionRepository {
  Stream<void> get changesStream;
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id);
  FutureOr<int?> save(MediaCollectionItem collectionItem);
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus> status,
  });
  FutureOr<void> delete(String supplier, String id) {}
}

class IsarCollectionRepository extends CollectionRepository {
  final Isar db = AppDatabase.database();
  late final IsarCollection<IsarMediaCollectionItem> collection =
      db.isarMediaCollectionItems;

  @override
  Stream<void> get changesStream => collection.watchLazy();
  @override
  FutureOr<MediaCollectionItem?> getCollectionItem(
      String supplier, String id) async {
    final collectionItem = await collection.getByIndex(
      "supplierId",
      [supplier, id],
    );

    return collectionItem?.toMediaCollectionItem();
  }

  @override
  FutureOr<int?> save(MediaCollectionItem collectionItem) async {
    if (collectionItem.status == MediaCollectionItemStatus.none) {
      await delete(collectionItem.supplier, collectionItem.id);
      return null;
    }

    final item =
        IsarMediaCollectionItem.fromMediaCollectionItem(collectionItem);

    return await db.writeTxn(
      () async => await collection.put(item),
    );
  }

  @override
  FutureOr<void> delete(String supplier, String id) async {
    return await db.writeTxn(
      () async => await collection.deleteByIndex(
        "supplierId",
        [supplier, id],
      ),
    );
  }

  @override
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
  }) async {
    final words = query != null ? Isar.splitWords(query) : const [];
    final statusList = status != null ? status.toList() : const [];

    final result = await collection
        .where()
        .optional(
          words.isNotEmpty,
          (q) {
            var ftsQ = q.ftsElementStartsWith(words[0]);

            for (var i = 1; i < words.length; i++) {
              ftsQ = ftsQ.or().ftsElementStartsWith(words[i]);
            }

            return ftsQ;
          },
        )
        .filter()
        .optional(
          statusList.isNotEmpty,
          (q) {
            var statusQ = q.statusEqualTo(statusList[0]);

            for (var i = 1; i < statusList.length; i++) {
              statusQ = statusQ.or().statusEqualTo(statusList[i]);
            }

            return statusQ;
          },
        )
        .sortByPriorityDesc()
        .thenByLastSeenDesc()
        .findAll();

    return result.map((e) => e.toMediaCollectionItem());
  }
}
