import 'dart:async';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_ffi/ffi_bridge.dart';
import 'package:content_suppliers_ffi/internal/schema_proto_generated.dart'
    as proto;

class FFIMediaItem implements ContentMediaItem {
  final String id;
  final String supplier;
  @override
  final int number;
  @override
  final String title;
  @override
  final String? section;
  @override
  final String? image;
  final FFIBridge _bridge;
  final List<String> _params;

  List<ContentMediaItemSource>? _sources;

  FFIMediaItem({
    required this.id,
    required this.supplier,
    required this.number,
    required this.title,
    required this.section,
    required this.image,
    required FFIBridge bridge,
    required List<String> params,
  })  : _bridge = bridge,
        _params = params;

  @override
  FutureOr<List<ContentMediaItemSource>> get sources async =>
      _sources ??= (await _bridge.loadMediaItemSources(supplier, id, _params))
          .map(
            (item) => switch (item.type) {
              proto.ContentMediaItemSourceType.Video =>
                SimpleContentMediaItemSource(
                  kind: FileKind.video,
                  description: item.description!,
                  link: Uri.parse(item.links!.first),
                  headers: _mapHeaders(item.headers),
                ),
              proto.ContentMediaItemSourceType.Subtitle =>
                SimpleContentMediaItemSource(
                  kind: FileKind.subtitle,
                  description: item.description!,
                  link: Uri.parse(item.links!.first),
                  headers: _mapHeaders(item.headers),
                ),
              proto.ContentMediaItemSourceType.Manga =>
                SimpleMangaMediaItemSource(
                  description: item.description!,
                  pages: item.links!,
                ),
              proto.ContentMediaItemSourceType() => throw UnimplementedError(),
            },
          )
          .toList();
}

Map<String, String>? _mapHeaders(List<proto.Header>? protoHeaders) {
  if (protoHeaders == null) {
    return null;
  }

  return {for (final h in protoHeaders) h.name!: h.value!};
}

// ignore: must_be_immutable
class FFIContentDetails extends AbstractContentDetails {
  final FFIBridge _bridge;
  final List<String> _params;
  @override
  final MediaType mediaType;
  Iterable<ContentMediaItem>? _mediaItems;

  FFIContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaType,
    required FFIBridge bridge,
    required List<String> params,
  })  : _bridge = bridge,
        _params = params;

  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems async =>
      _mediaItems ??= (await _bridge.loadMediaItems(supplier, id, _params))
          .map((item) => FFIMediaItem(
                id: id,
                supplier: supplier,
                number: item.number,
                title: item.title!,
                section: item.section,
                image: item.image,
                bridge: _bridge,
                params: item.params ?? [],
              ));
}

class FFIContentSupplier implements ContentSupplier {
  final FFIBridge _bridge;

  @override
  final String name;

  FFIContentSupplier({required this.name, required FFIBridge bridge})
      : _bridge = bridge;

  @override
  Set<String> get channels {
    return _bridge.channels(name).toSet();
  }

  @override
  Set<String> get defaultChannels {
    return _bridge.defaultChannels(name).toSet();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final result = await _bridge.getContentDetails(name, id);

    if (result == null) {
      return null;
    }

    return FFIContentDetails(
      id: id,
      supplier: name,
      mediaType: MediaType.values[result.mediaType.value],
      title: result.title!,
      originalTitle: result.originalTitle,
      image: result.image!,
      description: result.description!,
      additionalInfo: result.additionalInfo!,
      similar: (result.similar ?? [])
          .map(
            (e) => _mapSearchResult(name, e),
          )
          .toList(),
      bridge: _bridge,
      params: result.params ?? [],
    );
  }

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async {
    final results = await _bridge.loadChannel(name, channel, page);
    return results
        .map(
          (e) => _mapSearchResult(name, e),
        )
        .toList();
  }

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> types) async {
    final results = await _bridge.search(name, query, types);
    return results
        .map(
          (e) => _mapSearchResult(name, e),
        )
        .toList();
  }

  @override
  Set<ContentLanguage> get supportedLanguages {
    return _bridge
        .supportedLanguages(name)
        .map(
          (lang) => ContentLanguage.values.firstWhereOrNull(
            (v) => v.name == lang,
          ),
        )
        .nonNulls
        .toSet();
  }

  @override
  Set<ContentType> get supportedTypes {
    return _bridge
        .supportedTypes(name)
        .map((type) => ContentType.values[type.value])
        .toSet();
  }

  ContentSearchResult _mapSearchResult(String supplier, proto.ContentInfo ci) {
    return ContentSearchResult(
      id: ci.id!,
      supplier: supplier,
      image: ci.image!,
      title: ci.title!,
      secondaryTitle: ci.secondaryTitle,
    );
  }
}

class RustContentSuppliersBundle implements ContentSupplierBundle {
  final String directory;
  final String libName;
  FFIBridge? _bridge;

  RustContentSuppliersBundle({
    required this.directory,
    required this.libName,
  });

  Future<void> init() async {
    _bridge ??= FFIBridge.load(
      dir: directory,
      libName: libName,
    );
  }

  @override
  Future<List<ContentSupplier>> get suppliers async {
    final bridge = _bridge;

    if (bridge == null) {
      return [];
    }

    return bridge
        .avalaibleSuppliers()
        .map((supplier) => FFIContentSupplier(name: supplier, bridge: bridge))
        .toList();
  }
}
