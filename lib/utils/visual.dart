import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

const mobileWidth = 450.0;

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < mobileWidth;
}

float getPadding(BuildContext context) {
  return MediaQuery.of(context).size.width < mobileWidth ? 8.0 : 16.0;
}
