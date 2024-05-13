import 'package:cloud_hook/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@riverpod
class BrigthnesSetting extends _$BrigthnesSetting {
  @override
  Brightness? build() {
    return AppPreferences.themeBrightness;
  }

  void select(Brightness? brightness) {
    AppPreferences.themeBrightness = brightness;
    state = brightness;
  }
}

@riverpod
class ColorSettings extends _$ColorSettings {
  @override
  Color build() {
    return AppPreferences.themeColor;
  }

  void select(Color color) {
    AppPreferences.themeColor = color;
    state = color;
  }
}
