import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_repository.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_provider.g.dart';

@Riverpod(keepAlive: true)
CollectionRepository collectionItemRepository(Ref ref) {
  return IsarCollectionRepository();
}

@Riverpod(keepAlive: true)
class CollectionItemRepositoryChanges
    extends _$CollectionItemRepositoryChanges {
  @override
  Stream<void> build() {
    return ref.watch(collectionItemRepositoryProvider).changesStream;
  }
}

final collectionFilterQueryProvider = StateProvider<String>((ref) => "");

@Riverpod(keepAlive: true)
class CollectionItemStatusFilter extends _$CollectionItemStatusFilter {
  @override
  Set<MediaCollectionItemStatus> build() {
    var selectedStatus = Preferences.selectedCollectionItemStatus;

    selectedStatus ??= MediaCollectionItemStatus.values
        .where((element) => element != MediaCollectionItemStatus.none)
        .toSet();

    return Set.unmodifiable(selectedStatus);
  }

  void select(MediaCollectionItemStatus status) async {
    state = Set.from(state)..add(status);
    Preferences.selectedCollectionItemStatus = state;
  }

  void unselect(MediaCollectionItemStatus status) async {
    state = Set.from(state)..remove(status);
    Preferences.selectedCollectionItemStatus = state;
  }
}

@riverpod
FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>> collection(
  Ref ref,
) async {
  ref.watch(collectionItemRepositoryChangesProvider);

  final repository = ref.watch(collectionItemRepositoryProvider);
  final query = ref.watch(collectionFilterQueryProvider);
  final status = ref.watch(collectionItemStatusFilterProvider);

  final collectionItems = await repository.search(query: query, status: status);

  return Future.value(collectionItems.groupListsBy((e) => e.status));
}
