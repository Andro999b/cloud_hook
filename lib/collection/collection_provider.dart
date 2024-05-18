import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/auth/auth_provider.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_repository.dart';
import 'package:cloud_hook/collection/collection_service.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_provider.g.dart';

@Riverpod(keepAlive: true)
CollectionService collectionService(CollectionServiceRef ref) {
  final user = ref.watch(userProvider).valueOrNull;

  final repository = FirebaseRepository(
    downstream: IsarCollectionRepository(),
    user: user,
  );

  return CollectionService(repository: repository);
}

@Riverpod(keepAlive: true)
class CollectionChanges extends _$CollectionChanges {
  @override
  Stream<void> build() {
    return ref.watch(collectionServiceProvider).changesStream;
  }
}

final collectionFilterQueryProvider = StateProvider<String>((ref) => "");

@Riverpod(keepAlive: true)
class CollectionItemStatusFilter extends _$CollectionItemStatusFilter {
  @override
  Set<MediaCollectionItemStatus> build() {
    var selectedStatus = AppPreferences.selectedCollectionItemStatus;

    selectedStatus ??= MediaCollectionItemStatus.values
        .where((element) => element != MediaCollectionItemStatus.none)
        .toSet();

    return Set.unmodifiable(selectedStatus);
  }

  void select(MediaCollectionItemStatus status) async {
    state = Set.from(state)..add(status);
    AppPreferences.selectedCollectionItemStatus = state;
  }

  void unselect(MediaCollectionItemStatus status) async {
    state = Set.from(state)..remove(status);
    AppPreferences.selectedCollectionItemStatus = state;
  }
}

@riverpod
FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>> collection(
  CollectionRef ref,
) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);
  // ignore: avoid_manual_providers_as_generated_provider_dependency
  final query = ref.watch(collectionFilterQueryProvider);
  final status = ref.watch(collectionItemStatusFilterProvider);

  final collectionItems = await repository.search(query: query, status: status);

  return Future.value(collectionItems.groupListsBy((e) => e.status));
}
