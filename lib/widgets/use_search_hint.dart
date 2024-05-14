import 'package:flutter/material.dart';

class UseSearchHint extends StatelessWidget {
  const UseSearchHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search,
          size: 96,
        ),
        Text(
          "Ваша колекція порожня.\nСкористайтесь пошуком.",
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
