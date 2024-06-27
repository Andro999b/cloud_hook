import 'dart:async';

import 'package:cloud_hook/app_database.dart';
import 'package:cloud_hook/auth/auth.dart' as auth;
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_sync.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:firebase_dart/firebase_dart.dart';
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
    required this.status,
    required this.mediaType,
    this.currentItem,
    this.currentSource,
    this.currentSubtitle,
    this.positions,
    this.priority,
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
  String? secondaryTitle;
  final String image;
  @Enumerated(EnumType.ordinal)
  MediaType mediaType;
  int? currentItem;
  int? currentSource;
  int? currentSubtitle;
  List<IsarMediaItemPosition>? positions;

  @Enumerated(EnumType.ordinal)
  MediaCollectionItemStatus status;

  int? priority;
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
      mediaType: collectionItem.mediaType,
      currentItem: collectionItem.currentItem,
      currentSource: collectionItem.currentSource,
      currentSubtitle: collectionItem.currentSubtitle,
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
      mediaType: mediaType,
      currentItem: currentItem ?? 0,
      currentSource: currentSource ?? 0,
      currentSubtitle: currentSubtitle,
      positions: Map.fromEntries(
        positions?.map(
              (e) => MapEntry(
                e.number,
                MediaItemPosition(
                  position: e.position,
                  length: e.length,
                ),
              ),
            ) ??
            {},
      ),
      status: status,
      priority: priority ?? 0,
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
  FutureOr<int> save(MediaCollectionItem collectionItem);
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
  });
  FutureOr<void> delete(String supplier, String id);
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
    final collectionItem = await collection.getBySupplierId(supplier, id);

    return collectionItem?.toMediaCollectionItem();
  }

  @override
  FutureOr<int> save(MediaCollectionItem collectionItem) async {
    final item =
        IsarMediaCollectionItem.fromMediaCollectionItem(collectionItem);

    return await db.writeTxn(
      () async => await collection.put(item),
    );
  }

  @override
  FutureOr<void> delete(String supplier, String id) async {
    return await db.writeTxn(
      () async => await collection.deleteBySupplierId(supplier, id),
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

class FirebaseRepository extends CollectionRepository {
  final CollectionRepository downstream;
  final auth.User? user;
  late final FirebaseDatabase database;

  FirebaseRepository({
    required this.downstream,
    required this.user,
  }) {
    database = FirebaseDatabase(app: Firebase.app());

    if (user != null) {
      CollectionSync.run();
    }
  }

  @override
  Stream<void> get changesStream => downstream.changesStream;

  @override
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id) {
    return downstream.getCollectionItem(supplier, id);
  }

  @override
  FutureOr<int> save(MediaCollectionItem collectionItem) {
    _saveToFirebase(collectionItem);
    return downstream.save(collectionItem);
  }

  @override
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
  }) {
    return downstream.search(query: query, status: status);
  }

  @override
  FutureOr<void> delete(String supplier, String id) {
    _deleteFromFirebase(supplier, id);
    return downstream.delete(supplier, id);
  }

  Future<void> _saveToFirebase(MediaCollectionItem collectionItem) async {
    if (user == null) {
      return;
    }

    final itemId =
        "${collectionItem.supplier}${_sanitizeId(collectionItem.id)}";
    final ref = database.reference().child("collection/${user!.id}/$itemId");

    await ref.set(collectionItem.toJson());
  }

  Future<void> _deleteFromFirebase(String supplier, String id) async {
    if (user == null) {
      return;
    }

    final itemId = "$supplier${_sanitizeId(id)}";
    final ref = database.reference().child("collection/${user!.id}/$itemId");

    await ref.remove();
  }

  String _sanitizeId(String id) {
    return id.replaceAll("/", "|").replaceAll(".", "");
  }
}
