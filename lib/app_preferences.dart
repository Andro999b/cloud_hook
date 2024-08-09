import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/content/manga/model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late final SharedPreferences instance;
  static const Color defaultColor = Colors.green;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Set<ContentLanguage>? get selectedContentLanguage => instance
      .getStringList("selected_content_language")
      ?.map(
        (value) =>
            ContentLanguage.values.firstWhere((lang) => lang.name == value),
      )
      .nonNulls
      .toSet();

  static set selectedContentLanguage(Set<ContentLanguage>? value) =>
      instance.setStringList(
        "selected_content_language",
        value?.map((lang) => lang.name).toList() ?? List.empty(),
      );

  static Set<ContentType>? get selectedContentType => instance
      .getStringList("selected_content_type")
      ?.map(
        (value) => ContentType.values.firstWhere((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set selectedContentType(Set<ContentType>? value) =>
      instance.setStringList(
        "selected_content_type",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<String>? get selectedContentSuppliers =>
      instance.getStringList("selected_content_suppliers")?.toSet();

  static set selectedContentSuppliers(Set<String>? value) =>
      instance.setStringList(
        "selected_content_suppliers",
        value?.toList() ?? List.empty(),
      );

  static set themeBrightness(Brightness? brightness) => brightness != null
      ? instance.setString("theme_brightness", brightness.name)
      : instance.remove("theme_brightness");

  static Brightness? get themeBrightness => Brightness.values
      .where(
        (type) => type.name == instance.getString("theme_brightness"),
      )
      .firstOrNull;

  static set themeColor(Color color) =>
      instance.setInt("theme_color", color.value);

  static Color get themeColor {
    final colorValue = instance.getInt("theme_color");
    // colorValue
    return colorValue != null ? Color(colorValue) : defaultColor;
  }

  static Set<MediaType>? get collectionMediaType => instance
      .getStringList("collection_media_type")
      ?.map(
        (value) => MediaType.values.firstWhere((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set collectionMediaType(
    Set<MediaType>? value,
  ) =>
      instance.setStringList(
        "collection_media_type",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<MediaCollectionItemStatus>? get collectionItemStatus => instance
      .getStringList("collection_item_status")
      ?.map(
        (value) => MediaCollectionItemStatus.values
            .firstWhere((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set collectionItemStatus(
    Set<MediaCollectionItemStatus>? value,
  ) =>
      instance.setStringList(
        "collection_item_status",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<String>? get collectionContentSuppliers =>
      instance.getStringList("collection_content_suppliers")?.toSet();

  static set collectionContentSuppliers(Set<String>? value) =>
      instance.setStringList(
        "collection_content_suppliers",
        value?.toList() ?? List.empty(),
      );

  static int get lastSyncTimestamp =>
      instance.getInt("last_sync_timestamp") ?? 0;

  static set lastSyncTimestamp(int timestamp) =>
      instance.setInt("last_sync_timestamp", timestamp);

  static double get volume => instance.getDouble("volume") ?? 100.0;

  static set volume(double value) => instance.setDouble("volume", value);

  static List<String>? get suppliersOrder =>
      instance.getStringList("suppliers_order");

  static set suppliersOrder(List<String>? value) =>
      instance.setStringList("suppliers_order", value ?? []);

  static void setSupplierEnabled(
    String supplierName,
    bool enabled,
  ) {
    instance.setBool("suppliers.$supplierName.enabled", enabled);
  }

  static bool? getSupplierEnabled(String supplierName) =>
      instance.getBool("suppliers.$supplierName.enabled");

  static void setSupplierChannels(
    String supplierName,
    Set<String> channels,
  ) {
    instance.setStringList(
      "suppliers.$supplierName.channels",
      channels.toList(),
    );
  }

  static Set<String>? getSupplierChannels(String supplierName) =>
      instance.getStringList("suppliers.$supplierName.channels")?.toSet();

  static set mangaReaderImageMode(MangaReaderImageMode mode) =>
      instance.setString("manga_reader_image_mode", mode.name);

  static MangaReaderImageMode get mangaReaderImageMode =>
      MangaReaderImageMode.values
          .where(
            (type) =>
                type.name == instance.getString("manga_reader_image_mode"),
          )
          .firstOrNull ??
      MangaReaderImageMode.original;
}
