import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DisplayError extends StatelessWidget {
  final Object error;
  final VoidCallback? onRefresh;

  const DisplayError({
    super.key,
    required this.error,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error.toString(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go("/");
                  }
                },
                child: const Text("Повернутись назад"),
              ),
              if (onRefresh != null) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text("Повторити"),
                )
              ]
            ],
          )
        ],
      ),
    );
  }
}
