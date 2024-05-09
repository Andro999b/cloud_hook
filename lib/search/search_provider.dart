import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

final contentProviders = ContentSuppliers.instance;

@Riverpod(keepAlive: true)
class Search extends _$Search {
  @override
  SearchState build() => SearchState.empty;

  void search(String query, Set<String> contentSuppliers,
      Set<ContentType> contentTypes) async {
    final text = cleanupQuery(query);

    if (text.isEmpty) {
      return;
    }

    state = SearchState.loading(query);

    final stream =
        contentProviders.search(query, contentSuppliers, contentTypes);

    final subscription = stream.listen((event) {
      state = state.addResults(event);
    });

    subscription.onDone(() {
      state = state.loadingDone();
      subscription.cancel();
    });
  }
}

@riverpod
class SelectedSupplier extends _$SelectedSupplier {
  @override
  Set<String> build() {
    var selectedContentSuppliers = Preferences.selectedContentSuppliers;

    selectedContentSuppliers ??= ContentSuppliers.instance.suppliersName;

    return Set.unmodifiable(selectedContentSuppliers);
  }

  void select(String supplier) async {
    state = Set.from(state)..add(supplier);
    Preferences.selectedContentSuppliers = state;
  }

  void unselect(String supplier) async {
    state = Set.from(state)..remove(supplier);
    Preferences.selectedContentSuppliers = state;
  }
}

@riverpod
class SelectedContent extends _$SelectedContent {
  @override
  Set<ContentType> build() {
    var selectedContentTypes = Preferences.selectedContentType;

    selectedContentTypes ??= ContentType.values.toSet();

    return Set.unmodifiable(selectedContentTypes);
  }

  void select(ContentType type) async {
    state = Set.from(state)..add(type);
    Preferences.selectedContentType = state;
  }

  void unselect(ContentType type) async {
    state = Set.from(state)..remove(type);
    Preferences.selectedContentType = state;
  }
}
