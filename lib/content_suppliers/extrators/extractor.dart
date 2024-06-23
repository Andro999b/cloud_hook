import 'dart:async';

import 'package:cloud_hook/content_suppliers/model.dart';

abstract interface class ContentMediaItemExtractor {
  FutureOr<List<ContentMediaItem>> call();
}
