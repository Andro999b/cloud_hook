import 'package:cloud_hook/collection/collection_continue_view.dart';
import 'package:cloud_hook/home/recomendations/recomendations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';

class HomeScrean extends StatelessWidget {
  const HomeScrean({super.key});

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);

    return GeneralLayout(
      selectedIndex: 0,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: paddings),
        children: const [CollectionContinueView(), Recommendations()],
      ),
    );
  }
}
