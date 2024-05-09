// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playerjs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerJSFile _$PlayerJSFileFromJson(Map<String, dynamic> json) => PlayerJSFile(
      title: json['title'] as String,
      folder: (json['folder'] as List<dynamic>?)
          ?.map((e) => PlayerJSFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      poster: json['poster'] as String?,
      file: json['file'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$PlayerJSFileToJson(PlayerJSFile instance) =>
    <String, dynamic>{
      'title': instance.title,
      'folder': instance.folder,
      'poster': instance.poster,
      'file': instance.file,
      'subtitle': instance.subtitle,
    };
