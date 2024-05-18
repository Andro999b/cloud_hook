import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recomendations_provider.g.dart';

class RecomendationChannelState {
  final List<ContentInfo> recomendations;
  final bool hasNext;
  final int page;
  final bool loading;

  RecomendationChannelState({
    required this.recomendations,
    this.hasNext = true,
    this.page = 1,
    this.loading = false,
  });

  RecomendationChannelState copyWith({
    List<ContentInfo>? recomendations,
    bool? hasNext,
    int? page,
    bool? loading,
  }) {
    return RecomendationChannelState(
      recomendations: recomendations ?? this.recomendations,
      hasNext: hasNext ?? this.hasNext,
      page: page ?? this.page,
      loading: loading ?? this.loading,
    );
  }
}

@Riverpod(keepAlive: true)
class RecomendationChannel extends _$RecomendationChannel {
  @override
  FutureOr<RecomendationChannelState> build(
      String supplierName, String channel) async {
    final recomendations = await ContentSuppliers.instance
        .loadRecomendationsChannel(supplierName, channel);
    return RecomendationChannelState(recomendations: recomendations);
  }

  void loadNext() async {
    final current = state.requireValue;

    if (!current.hasNext) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(loading: true),
    );

    final nextPage = current.page + 1;
    final nextRecomendations = await ContentSuppliers.instance
        .loadRecomendationsChannel(supplierName, channel, page: nextPage);

    if (nextRecomendations.isEmpty) {
      state = AsyncValue.data(
        current.copyWith(
          loading: false,
          hasNext: false,
        ),
      );
    } else {
      state = AsyncValue.data(
        current.copyWith(
          loading: false,
          recomendations: current.recomendations + nextRecomendations,
          page: nextPage,
        ),
      );
    }
  }
}
