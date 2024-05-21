import 'package:cloud_hook/app_database.dart';
import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/auth/auth.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_repository.dart';
import 'package:firebase_dart/firebase_dart.dart';
// ignore: implementation_imports
import 'package:firebase_dart/src/database/impl/firebase_impl.dart';

class CollectionSync {
  CollectionSync._();

  static void run() async {
    // wait for user
    final user = Auth.instance.currentUser;
    if (user == null) {
      return;
    }

    // obtain databases
    final isar = AppDatabase.database();
    final firebase = FirebaseDatabase();

    // read local and remote collection
    final localCollection = isar.isarMediaCollectionItems;
    final ref = firebase.reference().child("collection/${user.id}");

    final lastSyncTimestamp = AppPreferences.lastSyncTimestamp;
    final nowTimestamp = DateTime.timestamp().millisecondsSinceEpoch;
    final remoteSnapshot = await ref
        .orderByChild("lastSeen")
        .startAt(lastSyncTimestamp)
        .once() as DataSnapshotImpl;

    final remoteCollection = remoteSnapshot.treeStructuredData.toJson(true);

    if (remoteCollection == null) {
      return;
    }

    isar.writeTxn(() async {
      // iterate remote items
      for (final remoteItemJson in remoteCollection.values) {
        var remoteItem = MediaCollectionItem.fromJson(remoteItemJson);
        final localItem = await localCollection.getBySupplierId(
          remoteItem.supplier,
          remoteItem.id,
        );

        // store newer remote items
        if (localItem == null ||
            remoteItem.lastSeen!.isAfter(localItem.lastSeen!)) {
          if (localItem != null) {
            // set local internalId
            remoteItem.internalId = localItem.isarId;
            // merge positions
            _mergePositions(remoteItem, localItem);
          }

          var isarMediaCollectionItem =
              IsarMediaCollectionItem.fromMediaCollectionItem(remoteItem);

          await localCollection.put(
            isarMediaCollectionItem,
          );
        }
      }
    });

    AppPreferences.lastSyncTimestamp = nowTimestamp;
  }

  static void _mergePositions(
    MediaCollectionItem remoteItem,
    IsarMediaCollectionItem localItem,
  ) {
    if (localItem.positions != null) {
      for (final localPosition in localItem.positions!) {
        if (!remoteItem.positions.containsKey(localPosition.number)) {
          remoteItem.positions[localPosition.number] = MediaItemPosition(
            position: localPosition.position,
            length: localPosition.length,
          );
        }
      }
    }
  }
}
