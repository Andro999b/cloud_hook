import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings_provider.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@Riverpod(keepAlive: true)
class Search extends _$Search {
  @override
  SearchState build() => SearchState.empty;

  void search(String query) async {
    final text = cleanupQuery(query);

    if (text.isEmpty) {
      return;
    }

    state = SearchState.loading(query);

    final contentSuppliers = ref.read(selectedSupplierProvider);
    final contentTypes = ref.read(selectedContentProvider);

    final stream =
        ContentSuppliers.instance.search(query, contentSuppliers, contentTypes);

    final subscription = stream.listen((event) {
      state = state.copyWith(results: event);
    });

    subscription.onDone(() {
      state = state.copyWith(isLoading: false);
      subscription.cancel();
    });
  }
}

@Riverpod(keepAlive: true)
class SelectedSupplier extends _$SelectedSupplier {
  @override
  Set<String> build() {
    final enabledSuppliers = ref.watch(enabledSuppliersProvider);
    var selectedContentSuppliers =
        AppPreferences.selectedContentSuppliers ?? enabledSuppliers;

    return selectedContentSuppliers.intersection(enabledSuppliers);
  }

  void select(String supplier) async {
    state = Set.from(state)..add(supplier);
    AppPreferences.selectedContentSuppliers = state;
  }

  void unselect(String supplier) async {
    state = Set.from(state)..remove(supplier);
    AppPreferences.selectedContentSuppliers = state;
  }
}

@Riverpod(keepAlive: true)
class SelectedContent extends _$SelectedContent {
  @override
  Set<ContentType> build() {
    var selectedContentTypes = AppPreferences.selectedContentType;

    selectedContentTypes ??= ContentType.values.toSet();

    return Set.unmodifiable(selectedContentTypes);
  }

  void select(ContentType type) async {
    state = Set.from(state)..add(type);
    AppPreferences.selectedContentType = state;
  }

  void unselect(ContentType type) async {
    state = Set.from(state)..remove(type);
    AppPreferences.selectedContentType = state;
  }
}
