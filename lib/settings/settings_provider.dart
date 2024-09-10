import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content/manga/model.dart';
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

@riverpod
class MangaReaderImageModeSettings extends _$MangaReaderImageModeSettings {
  @override
  MangaReaderImageMode build() {
    return AppPreferences.mangaReaderImageMode;
  }

  void select(MangaReaderImageMode mode) {
    AppPreferences.mangaReaderImageMode = mode;
    state = mode;
  }
}

@riverpod
class MangaReaderBackgroundSettings extends _$MangaReaderBackgroundSettings {
  @override
  MangaReaderBackground build() {
    return AppPreferences.mangaReaderBackground;
  }

  void select(MangaReaderBackground background) {
    AppPreferences.mangaReaderBackground = background;
    state = background;
  }
}
