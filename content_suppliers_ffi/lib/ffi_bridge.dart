import 'dart:async';
import 'dart:ffi';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:content_suppliers_api/model.dart';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:content_suppliers_ffi/internal/schema_proto_generated.dart'
    as proto;
import 'package:ffi/ffi.dart';

enum Command {
  suppliersList,
  channels,
  defaultChannels,
  supportedTypes,
  supportedLanguges,
  loadChannel,
  search,
  getContentDetails,
  loadMediaItems,
  loadMediaItemSources,
  test,
}

final class WireResult extends Struct {
  @Uint32()
  external int size;

  external Pointer<Uint8> buf;
  external Pointer<Utf8> error;
}

typedef WireCallback = Void Function(WireResult);

typedef WireFunction = void Function(
  int,
  int,
  Pointer<Uint8>,
  Pointer<NativeFunction<WireCallback>>,
);
typedef WireNativeFunction = Void Function(
  Uint8,
  Uint32,
  Pointer<Uint8>,
  Pointer<NativeFunction<WireCallback>>,
);

typedef WireSyncFunction = WireResult Function(
  int,
  int,
  Pointer<Uint8>,
);
typedef WireSyncNativeFunction = WireResult Function(
  Uint8,
  Uint32,
  Pointer<Uint8>,
);

typedef FreeFunction = void Function(WireResult);
typedef FreeNativeFunction = Void Function(WireResult);

class FFIBridge {
  WireFunction _wire;
  WireSyncFunction _wireSync;
  FreeFunction _free;

  FFIBridge._internal({
    required WireFunction wire,
    required WireSyncFunction wireSync,
    required FreeFunction free,
  })  : _wire = wire,
        _wireSync = wireSync,
        _free = free;

  factory FFIBridge.load({
    required String dir,
    required String libName,
  }) {
    var directory = io.Directory(dir);
    if (!directory.isAbsolute) {
      final currentPath = io.Directory.current.path;
      directory = io.Directory("$currentPath/$dir");
    }

    final libPath = "${directory.path}/$libName.so";

    if (!io.File(libPath).existsSync()) {
      throw Exception("Library path not found: $libPath");
    }

    final lib = DynamicLibrary.open(libPath);

    final wire = lib.lookupFunction<WireNativeFunction, WireFunction>("wire");
    final wireSync = lib
        .lookupFunction<WireSyncNativeFunction, WireSyncFunction>("wire_sync");
    final free = lib.lookupFunction<FreeNativeFunction, FreeFunction>("free");

    return FFIBridge._internal(
      wire: wire,
      wireSync: wireSync,
      free: free,
    );
  }

  List<String> avalaibleSuppliers() {
    final bytes = _sendBytesSync(Command.suppliersList);

    return proto.SuppliersRes(bytes).suppliers ?? [];
  }

  List<String> channels(String supplier) {
    final bytes = _sendBytesSync(
      Command.channels,
      _supplierNameReqBytes(supplier),
    );

    return proto.ChannelsRes(bytes).channels ?? [];
  }

  List<String> defaultChannels(String supplier) {
    final bytes = _sendBytesSync(
      Command.defaultChannels,
      _supplierNameReqBytes(supplier),
    );

    return proto.ChannelsRes(bytes).channels ?? [];
  }

  List<proto.ContentType> supportedTypes(String supplier) {
    final bytes = _sendBytesSync(
      Command.supportedTypes,
      _supplierNameReqBytes(supplier),
    );

    return proto.SupportedTypesRes(bytes).types ?? [];
  }

  List<String> supportedLanguages(String supplier) {
    final bytes = _sendBytesSync(
      Command.supportedLanguges,
      _supplierNameReqBytes(supplier),
    );

    return proto.SupportedLanuagesRes(bytes).langs ?? [];
  }

  Future<List<proto.ContentInfo>> loadChannel(
      String supplier, String channel, int page) async {
    final req = proto.LoadChannelsReqT(
      supplier: supplier,
      channel: channel,
      page: page,
    );

    final builder = fb.Builder();
    builder.finish(req.pack(builder));

    final res = await _sendBytes(Command.loadChannel, builder.buffer);

    return proto.ContentInfoRes(res).items ?? [];
  }

  Future<List<proto.ContentInfo>> search(
    String supplier,
    String query,
    Set<ContentType> types,
  ) async {
    final req = proto.SearchReqT(
      supplier: supplier,
      query: query,
      types: types.map((e) => proto.ContentType.fromValue(e.index)).toList(),
    );

    final builder = fb.Builder();
    builder.finish(req.pack(builder));

    final res = await _sendBytes(Command.search, builder.buffer);

    return proto.ContentInfoRes(res).items ?? [];
  }

  Future<proto.ContentDetails?> getContentDetails(
    String supplier,
    String id,
  ) async {
    final req = proto.ContentDetailsReqT(
      supplier: supplier,
      id: id,
    );

    final builder = fb.Builder();
    builder.finish(req.pack(builder));

    final res = await _sendBytes(Command.getContentDetails, builder.buffer);

    return proto.ContentDetailsRes(res).details;
  }

  Future<List<proto.ContentMediaItem>> loadMediaItems(
    String supplier,
    String id,
    List<String> params,
  ) async {
    final req = proto.LoadMediaItemsReqT(
      supplier: supplier,
      id: id,
      params: params,
    );

    final builder = fb.Builder();
    builder.finish(req.pack(builder));

    final res = await _sendBytes(Command.loadMediaItems, builder.buffer);

    return proto.LoadMediaItemsRes(res).mediaItems ?? [];
  }

  Future<List<proto.ContentMediaItemSource>> loadMediaItemSources(
    String supplier,
    String id,
    List<String> params,
  ) async {
    final req = proto.LoadMediaItemSourcesReqT(
      supplier: supplier,
      id: id,
      params: params,
    );

    final builder = fb.Builder();
    builder.finish(req.pack(builder));

    final res = await _sendBytes(Command.loadMediaItemSources, builder.buffer);

    return proto.LoadMediaItemSourcesRes(res).sources ?? [];
  }

  Uint8List _supplierNameReqBytes(String supplier) {
    final supNameReq = proto.SupplierNameReqT(supplier: supplier);

    final builder = fb.Builder();
    builder.finish(supNameReq.pack(builder));
    return builder.buffer;
  }

  Future<List<int>> _sendBytes(Command command, [List<int>? data]) {
    final dataPtr = data == null ? nullptr : _toNativePointer(data);

    final completer = Completer<List<int>>();
    late final NativeCallable<WireCallback> callback;
    void onResponse(WireResult result) {
      calloc.free(dataPtr);

      if (result.error != nullptr) {
        final error = result.error.toDartString();
        completer.completeError(Exception("FFI Error: $error"));
        return;
      }

      if (result.buf != nullptr) {
        final response = List.generate(result.size, (i) => result.buf[i]);

        completer.complete(response);
      } else {
        completer.completeError(Exception("No response for command: $command"));
      }

      _free(result);
      callback.close();
    }

    callback = NativeCallable<WireCallback>.listener(onResponse);

    _wire(
      command.index,
      data?.length ?? 0,
      dataPtr,
      callback.nativeFunction,
    );

    return completer.future;
  }

  List<int> _sendBytesSync(Command command, [List<int>? data]) {
    final dataPtr = data == null ? nullptr : _toNativePointer(data);

    final result = _wireSync(
      command.index,
      data?.length ?? 0,
      dataPtr,
    );

    calloc.free(dataPtr);

    if (result.error != nullptr) {
      final error = result.error.toDartString();
      _free(result);
      throw Exception("FFI Error: $error");
    }

    if (result.buf == nullptr) {
      _free(result);
      throw Exception("No response for command: $command");
    }

    final response = List.generate(result.size, (i) => result.buf[i]);

    _free(result);
    return response;
  }

  Pointer<Uint8> _toNativePointer(List<int> bytes) {
    final Pointer<Uint8> pointer = calloc.allocate<Uint8>(bytes.length);

    for (var i = 0; i < bytes.length; i++) {
      pointer[i] = bytes[i].toUnsigned(8);
    }

    return pointer;
  }
}
