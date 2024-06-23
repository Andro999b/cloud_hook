import 'package:cloud_hook/content/content_details_provider.dart';
import 'package:cloud_hook/content/video/video_content_view.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VideoContentScreen extends ConsumerWidget {
  const VideoContentScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(detailsAndMediaProvider(supplier, id));

    return SafeArea(
      child: AppTheme(
        child: Scaffold(
          body: result.when(
            data: (data) => VideoContentView(
              details: data.contentDetails,
              mediaItems: data.mediaItems,
            ),
            error: (error, stackTrace) => DisplayError(
              error: error,
              stackTrace: stackTrace,
              onRefresh: () =>
                  ref.refresh(detailsProvider(supplier, id).future),
            ),
            loading: () => const Material(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
