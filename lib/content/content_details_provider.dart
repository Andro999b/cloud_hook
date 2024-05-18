import 'dart:async';

import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_details_provider.g.dart';

@riverpod
Future<ContentDetails> details(DetailsRef ref, String supplier, String id) {
  final link = ref.keepAlive();

  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () {
      link.close();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  return ContentSuppliers.instance.detailsById(supplier, id);
}

@riverpod
Future<(ContentDetails, List<ContentMediaItem>)> detailsAndMedia(
  DetailsAndMediaRef ref,
  String supplier,
  String id,
) async {
  final contentDetails = await ref.read(detailsProvider(supplier, id).future);
  final mediaItems = await contentDetails.mediaItems;

  return (contentDetails, mediaItems.toList());
}
