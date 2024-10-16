import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef ExternalCallback = Void Function(Uint32, Pointer<Uint8>);
typedef ExternalFunction = void Function(
  int,
  Pointer<Uint8>,
  Pointer<NativeFunction<ExternalCallback>>,
);
typedef ExternalNativeFunction = Void Function(
  Uint32,
  Pointer<Uint8>,
  Pointer<NativeFunction<ExternalCallback>>,
);

class ExternalBridge {
  ExternalFunction _search;

  ExternalBridge._internal({
    required ExternalFunction search,
  }) : _search = search;

  factory ExternalBridge.load({
    required String dir,
    required String libName,
  }) {
    var directory = Directory(dir);
    if (!directory.isAbsolute) {
      final currentPath = Directory.current.path;
      directory = Directory("$currentPath/$dir");
    }

    final libPath = "${directory.path}/$libName.so";

    if (!File(libPath).existsSync()) {
      throw Exception("Library path not found: $libPath");
    }

    final lib = DynamicLibrary.open(libPath);

    final search =
        lib.lookupFunction<ExternalNativeFunction, ExternalFunction>("search");

    return ExternalBridge._internal(search: search);
  }

  Future<List<int>> search(List<int> data) {
    final dataPtr = _toNativePointer(data);

    final completer = Completer<List<int>>();
    late final NativeCallable<ExternalCallback> callback;
    void onResponse(int size, Pointer<Uint8> responsePointer) {
      final response = responsePointer.asTypedList(size);
      completer.complete(response);

      calloc.free(dataPtr);

      callback.close();
    }

    callback = NativeCallable<ExternalCallback>.listener(onResponse);

    _search(data.length, dataPtr, callback.nativeFunction);

    return completer.future;
  }

  Pointer<Uint8> _toNativePointer(List<int> bytes) {
    final Pointer<Uint8> pointer = calloc.allocate<Uint8>(bytes.length);

    for (var i = 0; i < bytes.length; i++) {
      pointer[i] = bytes[i].toUnsigned(8);
    }

    return pointer;
  }
}
