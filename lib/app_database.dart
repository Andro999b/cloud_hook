import 'package:cloud_hook/collection/collection_repository.dart';
import 'package:cloud_hook/search/search_top_bar/search_suggestion_model.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._();

  static late Isar _isar;

  static Future<void> init() async {
    final directory =
        "${(await getApplicationSupportDirectory()).path}/.cloud_hook";

    logger.i("Database directory: $directory");

    _isar = await Isar.open(
      [SearchSuggestionSchema, IsarMediaCollectionItemSchema],
      directory: directory,
    );
  }

  static Isar database() {
    return _isar;
  }
}
