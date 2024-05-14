import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late final SharedPreferences instance;
  static const Color defaultColor = Colors.green;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Set<String>? get selectedContentSuppliers =>
      instance.getStringList("selected_content_suppliers")?.toSet();

  static set selectedContentSuppliers(Set<String>? value) =>
      instance.setStringList(
        "selected_content_suppliers",
        value?.toList() ?? List.empty(),
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

  static set themeBrightness(Brightness? brightness) => brightness != null
      ? instance.setString("theme_brightness", brightness.name)
      : instance.remove("brightness");

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

  static Set<MediaCollectionItemStatus>? get selectedCollectionItemStatus =>
      instance
          .getStringList("collection_item_status")
          ?.map(
            (value) => MediaCollectionItemStatus.values
                .firstWhere((type) => type.name == value),
          )
          .nonNulls
          .toSet();

  static set selectedCollectionItemStatus(
    Set<MediaCollectionItemStatus>? value,
  ) =>
      instance.setStringList(
        "collection_item_status",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static int get lastSyncTimestamp =>
      instance.getInt("last_sync_timestamp") ?? 0;

  static set lastSyncTimestamp(int timestamp) =>
      instance.setInt("last_sync_timestamp", timestamp);

  static double get volume => instance.getDouble("volume") ?? 100.0;

  static set volume(double value) => instance.setDouble("volume", value);

  static List<String>? get recomendationsOrder =>
      instance.getStringList("recomendations_order");

  static set recomendationsOrder(List<String>? value) =>
      instance.setStringList("recomendations_order", value ?? []);

  static void setRecomendationSupplierEnabled(
    String supplierName,
    bool enabled,
  ) {
    instance.setBool("recomendations.$supplierName.enabled", enabled);
  }

  static bool? getRecomendationSupplierEnabled(String supplierName) =>
      instance.getBool("recomendations.$supplierName.enabled");

  static void setRecomendationSupplierChannels(
    String supplierName,
    Set<String> channels,
  ) {
    instance.setStringList(
      "recomendations.$supplierName.channels",
      channels.toList(),
    );
  }

  static Set<String>? getRecomendationSupplierChannels(String supplierName) =>
      instance.getStringList("recomendations.$supplierName.channels")?.toSet();
}
