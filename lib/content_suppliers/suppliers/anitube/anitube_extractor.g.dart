// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anitube_extractor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Label _$LabelFromJson(Map<String, dynamic> json) => Label(
      json['lable'] as String,
      json['id'] as String,
    );

EpisodeVideo _$EpisodeVideoFromJson(Map<String, dynamic> json) => EpisodeVideo(
      json['id'] as String,
      json['name'] as String,
      json['file'] as String,
    );

PlaylistResults _$PlaylistResultsFromJson(Map<String, dynamic> json) =>
    PlaylistResults(
      (json['videos'] as List<dynamic>)
          .map((e) => EpisodeVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['lables'] as List<dynamic>)
          .map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
