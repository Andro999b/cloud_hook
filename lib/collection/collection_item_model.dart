import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'collection_item_model.g.dart';

enum MediaCollectionItemStatus {
  none,
  latter,
  inProgress,
  complete,
  onHold,
}

DateTime? _dateTimeFormMilli(value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}

int? _dateTimeToMilli(DateTime? value) {
  return value?.millisecondsSinceEpoch;
}

@JsonSerializable()
class MediaCollectionItem with ContentInfo, ContentProgress {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
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

  final MediaCollectionItemStatus status;
  final int priority;

  @JsonKey(
    fromJson: _dateTimeFormMilli,
    toJson: _dateTimeToMilli,
  )
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
      positions: positions != null
          ? {...this.positions, ...positions}
          : this.positions,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      internalId: internalId,
      lastSeen: lastSeen,
    );
  }

  factory MediaCollectionItem.fromJson(Map<String, dynamic> json) =>
      _$MediaCollectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaCollectionItemToJson(this);
}

@immutable
@JsonSerializable()
class MediaItemPosition extends Equatable {
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

  factory MediaItemPosition.fromJson(Map<String, dynamic> json) =>
      _$MediaItemPositionFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemPositionToJson(this);

  @override
  List<Object?> get props => [position, length];
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
