import 'package:cloud_hook/app_preferences.dart';
import 'package:cloud_hook/content_suppliers/content_suppliers.dart';
import 'package:cloud_hook/search/search_model.dart';
import 'package:cloud_hook/settings/suppliers/suppliers_settings_provider.dart';
import 'package:cloud_hook/utils/collections.dart';
import 'package:cloud_hook/utils/text.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

    final enabledSuppliers = ref.read(enabledSuppliersProvider);
    final searchSettings = ref.read(searchSettingsProvider);
    final contentSuppliers = enabledSuppliers.intersection(
      searchSettings.searchSuppliersNames,
    );

    final stream = ContentSuppliers.instance.search(
      query,
      contentSuppliers,
      searchSettings.types,
    );

    final subscription = stream.listen((event) {
      state = state.copyWith(results: event);
    });

    subscription.onDone(() {
      state = state.copyWith(isLoading: false);
      subscription.cancel();
    });
  }
}

@immutable
class SearchSettingsModel extends Equatable {
  final Set<ContentLanguage> languages;
  final Set<ContentType> types;
  final Set<String> suppliersNames;

  const SearchSettingsModel({
    required this.languages,
    required this.types,
    required this.suppliersNames,
  });

  Set<String> get avaliableSuppliers =>
      ContentSuppliers.instance.suppliersName.where((supplierName) {
        final supplier = ContentSuppliers.instance.getSupplier(supplierName)!;
        return languages.intersection(supplier.supportedLanguages).isNotEmpty &&
            types.intersection(supplier.supportedTypes).isNotEmpty;
      }).toSet();

  Set<String> get searchSuppliersNames =>
      suppliersNames.intersection(avaliableSuppliers);

  @override
  List<Object?> get props => [languages, types, suppliersNames];

  SearchSettingsModel copyWith({
    Set<ContentLanguage>? languages,
    Set<ContentType>? types,
    Set<String>? suppliersNames,
  }) {
    return SearchSettingsModel(
      languages: languages ?? this.languages,
      types: types ?? this.types,
      suppliersNames: suppliersNames ?? this.suppliersNames,
    );
  }
}

@riverpod
class SearchSettings extends _$SearchSettings {
  @override
  SearchSettingsModel build() {
    return SearchSettingsModel(
        languages: AppPreferences.selectedContentLanguage ??
            ContentLanguage.values.toSet(),
        types: AppPreferences.selectedContentType ?? ContentType.values.toSet(),
        suppliersNames: AppPreferences.collectionContentSuppliers ??
            ContentSuppliers.instance.suppliersName);
  }

  void toggleLanguage(ContentLanguage lang) {
    final newLanuages = state.languages.toggle(lang);
    state = state.copyWith(languages: newLanuages);
    AppPreferences.selectedContentLanguage = newLanuages;
  }

  void toggleType(ContentType type) {
    final newTypes = state.types.toggle(type);
    state = state.copyWith(types: newTypes);
    AppPreferences.selectedContentType = newTypes;
  }

  void toggleSupplierName(String supplierName) {
    final newSupplierNames = state.suppliersNames.toggle(supplierName);
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }

  void toggleAllSuppliers(bool select) {
    final newSupplierNames =
        select ? ContentSuppliers.instance.suppliersName : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }
}
