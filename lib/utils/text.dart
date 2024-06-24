import 'package:flutter/material.dart';

String cleanupQuery(String text) {
  return text.trim().replaceAll('\\s', '\\s');
}

int extractDigits(String text) {
  int acc = 0;
  bool found = false;

  for (final ch in text.characters) {
    final num = int.tryParse(ch);
    if (num != null) {
      found = true;
      acc = acc * 10 + num;
    } else if (found) {
      break;
    }
  }

  return acc;
}
