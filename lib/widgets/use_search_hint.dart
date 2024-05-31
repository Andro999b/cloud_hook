import 'package:cloud_hook/app_localizations.dart';
import 'package:flutter/material.dart';

class UseSearchHint extends StatelessWidget {
  const UseSearchHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.search,
          size: 96,
        ),
        Text(
          AppLocalizations.of(context)!.useSearchHint,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
