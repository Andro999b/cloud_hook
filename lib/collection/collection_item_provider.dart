import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_provider.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_item_provider.g.dart';

@riverpod
class CollectionItem extends _$CollectionItem {
  @override
  FutureOr<MediaCollectionItem> build(ContentDetails details) async {
    final repository = ref.read(collectionServiceProvider);
    final item = await repository.getCollectionItem(
      details.supplier,
      details.id,
    );

    return item?.copyWith(title: details.title, image: details.image) ??
        MediaCollectionItem.fromContentDetails(details);
  }

  void setCurrentItem(int itemIdx) async {
    final value = state.requireValue;
    final newValue = value.copyWith(
      currentItem: itemIdx,
      status: MediaCollectionItemStatus.inProgress,
    );

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentSource(int sourceIdx) async {
    final value = state.requireValue;
    final newValue = value.copyWith(
      currentSource: sourceIdx,
      status: MediaCollectionItemStatus.inProgress,
    );

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentSubtitle(int? subtitleIdx) async {
    final value = state.requireValue;
    final newValue = value.copyWith(
      currentSubtitle: () => subtitleIdx,
      status: MediaCollectionItemStatus.inProgress,
    );

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentPosition(int position, int length) async {
    final value = state.requireValue;
    final currentItemPosition = value.currentItemPosition;

    if ((currentItemPosition.position - position).abs() > 10) {
      final newValue = value.copyWith(
        positions: {
          value.currentItem: currentItemPosition.copyWith(
            position: position,
            length: length,
          ),
        },
        status: MediaCollectionItemStatus.inProgress,
      );

      state = await AsyncValue.guard(() => _saveNewValue(newValue));
    }
  }

  void setStatus(MediaCollectionItemStatus status) async {
    final value = state.requireValue;
    final newValue = value.copyWith(status: status);

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setPriorit(int priority) async {
    final value = state.requireValue;

    if (value.status != MediaCollectionItemStatus.none) {
      final newValue = value.copyWith(priority: priority);

      state = await AsyncValue.guard(() => _saveNewValue(newValue));
    }
  }

  Future<MediaCollectionItem> _saveNewValue(
    MediaCollectionItem newValue,
  ) async {
    final service = ref.read(collectionServiceProvider);

    await service.save(newValue);

    return newValue;
  }
}
