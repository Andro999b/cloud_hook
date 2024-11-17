import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/search/search_view.dart';
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
