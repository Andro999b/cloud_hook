import 'dart:convert';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppInitFirebase {
  AppInitFirebase._();

  static Future<FirebaseOptions> loadOptions() async {
    final firebaseOptionsJson =
        await rootBundle.loadString("firebase_config.json");

    return FirebaseOptions.fromMap(
      json.decode(firebaseOptionsJson),
    );
  }

  static Future<FirebaseApp> init({
    isolated = true,
    FirebaseOptions? options,
  }) async {
    final directory =
        "${(await getApplicationSupportDirectory()).path}/firebase";

    FirebaseDart.setup(storagePath: directory, isolated: isolated);

    return await Firebase.initializeApp(
      options: options ?? await loadOptions(),
    );
  }
}
