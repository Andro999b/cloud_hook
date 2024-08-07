import 'package:cloud_hook/content/content_details_provider.dart';
import 'package:cloud_hook/content/manga/manga_content_view.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MangaContentScrean extends ConsumerWidget {
  const MangaContentScrean({
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
            data: (data) => MangaContentView(
              contentDetails: data.contentDetails,
              mediaItems: data.mediaItems,
            ),
            error: (error, stackTrace) => DisplayError(
              error: error,
              stackTrace: stackTrace,
              onRefresh: () =>
                  ref.refresh(detailsProvider(supplier, id).future),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
