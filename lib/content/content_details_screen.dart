import 'package:cloud_hook/content/content_details_provider.dart';
import 'package:cloud_hook/content/content_details_view.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ContentDetailsScreen extends ConsumerWidget {
  const ContentDetailsScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(detailsProvider(supplier, id));

    return GeneralLayout(
      showBackButton: true,
      selectedIndex: 2,
      child: details.when(
        data: (data) => ContentDetailsView(data),
        error: (error, stackTrace) => DisplayError(
          error: error,
          stackTrace: stackTrace,
          onRefresh: () => ref.refresh(detailsProvider(supplier, id).future),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
