// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

// Static analysis wrongly picks the IO variant, thus ignore this
// ignore_for_file: argument_type_not_assignable

import 'api.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'models.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_web.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw);

  @protected
  Map<String, String> dco_decode_Map_String_String(dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  ContentDetails dco_decode_box_autoadd_content_details(dynamic raw);

  @protected
  ContentDetails dco_decode_content_details(dynamic raw);

  @protected
  ContentInfo dco_decode_content_info(dynamic raw);

  @protected
  ContentMediaItem dco_decode_content_media_item(dynamic raw);

  @protected
  ContentMediaItemSource dco_decode_content_media_item_source(dynamic raw);

  @protected
  ContentType dco_decode_content_type(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  List<ContentInfo> dco_decode_list_content_info(dynamic raw);

  @protected
  List<ContentMediaItem> dco_decode_list_content_media_item(dynamic raw);

  @protected
  List<ContentMediaItemSource> dco_decode_list_content_media_item_source(
      dynamic raw);

  @protected
  List<ContentType> dco_decode_list_content_type(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  List<(String, String)> dco_decode_list_record_string_string(dynamic raw);

  @protected
  MediaType dco_decode_media_type(dynamic raw);

  @protected
  Map<String, String>? dco_decode_opt_Map_String_String(dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  ContentDetails? dco_decode_opt_box_autoadd_content_details(dynamic raw);

  @protected
  List<ContentMediaItemSource>? dco_decode_opt_list_content_media_item_source(
      dynamic raw);

  @protected
  (String, String) dco_decode_record_string_string(dynamic raw);

  @protected
  int dco_decode_u_16(dynamic raw);

  @protected
  int dco_decode_u_32(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer);

  @protected
  Map<String, String> sse_decode_Map_String_String(
      SseDeserializer deserializer);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  ContentDetails sse_decode_box_autoadd_content_details(
      SseDeserializer deserializer);

  @protected
  ContentDetails sse_decode_content_details(SseDeserializer deserializer);

  @protected
  ContentInfo sse_decode_content_info(SseDeserializer deserializer);

  @protected
  ContentMediaItem sse_decode_content_media_item(SseDeserializer deserializer);

  @protected
  ContentMediaItemSource sse_decode_content_media_item_source(
      SseDeserializer deserializer);

  @protected
  ContentType sse_decode_content_type(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  List<ContentInfo> sse_decode_list_content_info(SseDeserializer deserializer);

  @protected
  List<ContentMediaItem> sse_decode_list_content_media_item(
      SseDeserializer deserializer);

  @protected
  List<ContentMediaItemSource> sse_decode_list_content_media_item_source(
      SseDeserializer deserializer);

  @protected
  List<ContentType> sse_decode_list_content_type(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  List<(String, String)> sse_decode_list_record_string_string(
      SseDeserializer deserializer);

  @protected
  MediaType sse_decode_media_type(SseDeserializer deserializer);

  @protected
  Map<String, String>? sse_decode_opt_Map_String_String(
      SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  ContentDetails? sse_decode_opt_box_autoadd_content_details(
      SseDeserializer deserializer);

  @protected
  List<ContentMediaItemSource>? sse_decode_opt_list_content_media_item_source(
      SseDeserializer deserializer);

  @protected
  (String, String) sse_decode_record_string_string(
      SseDeserializer deserializer);

  @protected
  int sse_decode_u_16(SseDeserializer deserializer);

  @protected
  int sse_decode_u_32(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  void sse_encode_AnyhowException(
      AnyhowException self, SseSerializer serializer);

  @protected
  void sse_encode_Map_String_String(
      Map<String, String> self, SseSerializer serializer);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_content_details(
      ContentDetails self, SseSerializer serializer);

  @protected
  void sse_encode_content_details(
      ContentDetails self, SseSerializer serializer);

  @protected
  void sse_encode_content_info(ContentInfo self, SseSerializer serializer);

  @protected
  void sse_encode_content_media_item(
      ContentMediaItem self, SseSerializer serializer);

  @protected
  void sse_encode_content_media_item_source(
      ContentMediaItemSource self, SseSerializer serializer);

  @protected
  void sse_encode_content_type(ContentType self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_content_info(
      List<ContentInfo> self, SseSerializer serializer);

  @protected
  void sse_encode_list_content_media_item(
      List<ContentMediaItem> self, SseSerializer serializer);

  @protected
  void sse_encode_list_content_media_item_source(
      List<ContentMediaItemSource> self, SseSerializer serializer);

  @protected
  void sse_encode_list_content_type(
      List<ContentType> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_string_string(
      List<(String, String)> self, SseSerializer serializer);

  @protected
  void sse_encode_media_type(MediaType self, SseSerializer serializer);

  @protected
  void sse_encode_opt_Map_String_String(
      Map<String, String>? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_content_details(
      ContentDetails? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_list_content_media_item_source(
      List<ContentMediaItemSource>? self, SseSerializer serializer);

  @protected
  void sse_encode_record_string_string(
      (String, String) self, SseSerializer serializer);

  @protected
  void sse_encode_u_16(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire implements BaseWire {
  RustLibWire.fromExternalLibrary(ExternalLibrary lib);
}

@JS('wasm_bindgen')
external RustLibWasmModule get wasmModule;

@JS()
@anonymous
extension type RustLibWasmModule._(JSObject _) implements JSObject {}
