import 'package:cloud_hook/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@riverpod
class BrigthnesSetting extends _$BrigthnesSetting {
  @override
  Brightness? build() {
    return Preferences.themeBrightness;
  }

  void select(Brightness? brightness) {
    Preferences.themeBrightness = brightness;
    state = brightness;
  }
}

@riverpod
class ColorSettings extends _$ColorSettings {
  @override
  Color build() {
    return Preferences.themeColor;
  }

  void select(Color color) {
    Preferences.themeColor = color;
    state = color;
  }
}
