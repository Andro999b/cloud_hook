import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';

enum MediaCollectionItemStatus {
  none,
  latter,
  inProgress,
  complete,
  onHold,
}

class MediaCollectionItem with ContentInfo, ContentProgress {
  int? internalId; // for database

  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  final String image;
  @override
  String? get subtitle => null;
  @override
  int currentItem;
  @override
  int currentSource;
  @override
  Map<int, MediaItemPosition> positions;

  MediaCollectionItemStatus status;
  int priority;

  DateTime? lastSeen;

  MediaCollectionItem({
    required this.id,
    required this.supplier,
    required this.title,
    required this.image,
    this.currentItem = 0,
    this.currentSource = 0,
    this.positions = const {},
    this.status = MediaCollectionItemStatus.none,
    this.priority = 1,
    this.internalId,
    this.lastSeen,
  });

  factory MediaCollectionItem.fromContentDetails(ContentDetails details) =>
      MediaCollectionItem(
        id: details.id,
        supplier: details.supplier,
        image: details.image,
        title: details.title,
      );

  MediaCollectionItem copyWith({
    String? title,
    String? image,
    int? currentItem,
    int? currentSource,
    Map<int, MediaItemPosition>? positions,
    MediaCollectionItemStatus? status,
    int? priority,
  }) {
    return MediaCollectionItem(
      id: id,
      supplier: supplier,
      title: title ?? this.title,
      image: image ?? this.image,
      currentItem: currentItem ?? this.currentItem,
      currentSource: currentSource ?? this.currentSource,
      positions: {...this.positions, if (positions != null) ...positions},
      status: status ?? this.status,
      priority: priority ?? this.priority,
      internalId: internalId,
    );
  }
}

@immutable
class MediaItemPosition {
  final int position;
  final int length;

  const MediaItemPosition({
    required this.position,
    required this.length,
  });

  double get progress => length != 0 ? position / length : 0;

  MediaItemPosition copyWith({
    int? position,
    int? length,
  }) {
    return MediaItemPosition(
      position: position ?? this.position,
      length: length ?? this.length,
    );
  }

  static MediaItemPosition zero = const MediaItemPosition(
    position: 0,
    length: 0,
  );
}

mixin ContentProgress {
  String get id;
  String get supplier;

  int get currentItem;
  int get currentSource;

  Map<int, MediaItemPosition> get positions;

  int get currentPosition => positions[currentItem]?.position ?? 0;
  MediaItemPosition get currentItemPosition =>
      positions[currentItem] ?? MediaItemPosition.zero;
}
