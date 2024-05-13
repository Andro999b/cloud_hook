import 'package:cloud_hook/utils/logger.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:path_provider/path_provider.dart';

class AppImageCache {
  AppImageCache._();

  static Future<void> init() async {
    String storageLocation =
        "${(await getApplicationSupportDirectory()).path}/images";

    logger.i("Image cache directory: $storageLocation");

    await FastCachedImageConfig.init(
      subDir: storageLocation,
      clearCacheAfter: const Duration(days: 15),
    );
  }
}
