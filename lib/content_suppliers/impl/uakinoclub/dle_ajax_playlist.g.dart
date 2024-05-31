// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dle_ajax_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AjaxPlaylistItem _$AjaxPlaylistItemFromJson(Map<String, dynamic> json) =>
    _AjaxPlaylistItem(
      id: json['id'] as String,
      text: json['text'] as String,
      link: json['link'] as String,
      voice: json['voice'] as String?,
    );

Map<String, dynamic> _$AjaxPlaylistItemToJson(_AjaxPlaylistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'link': instance.link,
      'voice': instance.voice,
    };
