import 'dart:io';

import 'package:strumok/utils/android_tv.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

const mobileWidth = 450.0;

bool isMobile(BuildContext context) {
  return MediaQuery.sizeOf(context).width < mobileWidth;
}

float getPadding(BuildContext context) {
  return MediaQuery.sizeOf(context).width < mobileWidth ? 8.0 : 16.0;
}

bool isMobileDevice() {
  return Platform.isIOS || (Platform.isAndroid && !AndroidTVDetector.isTV);
}

bool isDesktopDevice() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
