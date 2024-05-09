import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackNavButton extends StatelessWidget {
  final Color? color;

  const BackNavButton({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: color,
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go("/");
        }
      },
    );
  }
}
