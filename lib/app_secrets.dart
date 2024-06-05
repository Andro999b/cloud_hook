import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class AppSecrets {
  static late final Map<String, dynamic> _secrets;

  static Future<void> init() async {
    final secretsContent = await rootBundle.loadString("secrets.json");
    _secrets = await json.decode(secretsContent);
  }

  static String getString(String key) {
    return _secrets[key] as String;
  }

  static Map<String, dynamic> getJson(String key) {
    return _secrets[key] as Map<String, dynamic>;
  }
}
