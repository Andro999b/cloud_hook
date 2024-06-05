import 'package:cloud_hook/app_secrets.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:path_provider/path_provider.dart';

class AppInitFirebase {
  AppInitFirebase._();

  static Future<FirebaseOptions> loadOptions() async {
    final firebaseOptionsJson = AppSecrets.getJson("firebase");
    return FirebaseOptions.fromMap(
      firebaseOptionsJson,
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
