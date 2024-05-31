import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/search/search_view.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 1,
      child: SearchView(),
    );
  }
}
