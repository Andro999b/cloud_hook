import 'package:cloud_hook/collection/active_collection_items_view.dart';
import 'package:cloud_hook/home/recomendations/recomendations.dart';
import 'package:cloud_hook/layouts/general_layout.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScrean extends StatelessWidget {
  const HomeScrean({super.key});

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);

    return GeneralLayout(
      selectedIndex: 0,
      child: ListView(
        padding: EdgeInsets.only(top: paddings),
        children: const [ActiveCollectionItemsView(), Recommendations()],
      ),
    );
  }
}
