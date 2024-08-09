import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/auth/auth_provider.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_repository.dart';
import 'package:cloud_hook/collection/collection_service.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/collections.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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

@riverpod
FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>> collection(
    CollectionRef ref) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);
  // ignore: avoid_manual_providers_as_generated_provider_dependency
  final query = ref.watch(collectionFilterQueryProvider);
  final collectionFilter = ref.watch(collectionFilterProvider);

  final collectionItems = await repository.search(
    query: query,
    status: collectionFilter.status,
    mediaTypes: collectionFilter.mediaTypes,
    suppliersNames: collectionFilter.suppliersNames,
  );

  return Future.value(collectionItems.groupListsBy((e) => e.status));
}

@riverpod
FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>
    collectionActiveItems(CollectionActiveItemsRef ref) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);

  final collectionItems = await repository.search(status: {
    MediaCollectionItemStatus.inProgress,
    MediaCollectionItemStatus.latter,
  });

  return Future.value(collectionItems.groupListsBy((e) => e.status));
}

@immutable
class CollectionFilterModel extends Equatable {
  final Set<MediaCollectionItemStatus> status;
  final Set<MediaType> mediaTypes;
  final Set<String> suppliersNames;

  const CollectionFilterModel({
    required this.status,
    required this.mediaTypes,
    required this.suppliersNames,
  });

  @override
  List<Object?> get props => [status, mediaTypes, suppliersNames];

  CollectionFilterModel copyWith({
    Set<MediaCollectionItemStatus>? status,
    Set<MediaType>? mediaTypes,
    Set<String>? suppliersNames,
  }) {
    return CollectionFilterModel(
      status: status ?? this.status,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      suppliersNames: suppliersNames ?? this.suppliersNames,
    );
  }
}

@riverpod
class CollectionFilter extends _$CollectionFilter {
  @override
  CollectionFilterModel build() {
    return CollectionFilterModel(
      status: AppPreferences.collectionItemStatus ??
          MediaCollectionItemStatus.values.toSet(),
      mediaTypes:
          AppPreferences.collectionMediaType ?? MediaType.values.toSet(),
      suppliersNames: AppPreferences.collectionContentSuppliers ??
          ContentSuppliers.instance.suppliersName,
    );
  }

  void toggleStatus(MediaCollectionItemStatus status) {
    final newStatus = state.status.toggle(status);
    state = state.copyWith(status: newStatus);
    AppPreferences.collectionItemStatus = newStatus;
  }

  void toggleMediaType(MediaType mediaType) {
    final newMediaTypes = state.mediaTypes.toggle(mediaType);
    state = state.copyWith(mediaTypes: newMediaTypes);
    AppPreferences.collectionMediaType = newMediaTypes;
  }

  void toggleSupplierName(String supplierName) {
    final newSupplierNames = state.suppliersNames.toggle(supplierName);
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }

  void toggleAllSuppliers(bool select) {
    final newSupplierNames =
        select ? ContentSuppliers.instance.suppliersName : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }
}
