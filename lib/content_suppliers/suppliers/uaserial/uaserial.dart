import 'package:cloud_hook/content_suppliers/model.dart';

class UASerialSupplier extends ContentSupplier {
  @override
  String get name => "uaserial";

  @override
  Set<ContentLanguage> get supportedLanguages => const {
        ContentLanguage.ukrainian,
      };

  @override
  Set<ContentType> get supportedTypes => const {
        ContentType.movie,
        ContentType.cartoon,
        ContentType.series,
        ContentType.anime,
      };
}
