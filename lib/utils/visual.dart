import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

const mobileWidth = 450.0;

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < mobileWidth;
}

float getPadding(BuildContext context) {
  return MediaQuery.of(context).size.width < mobileWidth ? 8.0 : 16.0;
}

Future<bool> isAndroidTV() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  // Check for the presence of features typical of Android TV
  bool isTV = androidInfo.systemFeatures.contains('android.software.leanback');

  return isTV;
}
