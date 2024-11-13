import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ffi_supplier_bundle_info.g.dart';

@JsonSerializable()
class FFISupplierBundleInfo extends Equatable {
  final String name;
  final String version;
  final String metadataUrl;
  final Map<String, String> downloadUrl;

  const FFISupplierBundleInfo({
    required this.name,
    required this.version,
    required this.metadataUrl,
    required this.downloadUrl,
  });

  Map<String, dynamic> toJson() => _$FFISupplierBundleInfoToJson(this);

  factory FFISupplierBundleInfo.fromJson(Map<String, dynamic> json) =>
      _$FFISupplierBundleInfoFromJson(json);

  @override
  List<Object?> get props => [name];
}
