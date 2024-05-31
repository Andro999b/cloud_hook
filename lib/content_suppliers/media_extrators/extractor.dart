import 'dart:async';

import 'package:cloud_hook/content_suppliers/model.dart';

mixin MediaExtractor {
  FutureOr<List<ContentMediaItem>> extract(String iframe);
}
