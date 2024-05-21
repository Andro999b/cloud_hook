import 'package:cloud_hook/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colors = [
  Colors.deepOrange,
  Colors.amber,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.blueGrey,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.deepPurple,
];

class ColorSwitcher extends ConsumerWidget {
  const ColorSwitcher({super.key});

  Widget renderColorSelector(Color color, Color selected, WidgetRef ref) {
    final icon = color.value == selected.value
        ? const Icon(
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
              )
            ],
            Icons.check,
          )
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkResponse(
        onTap: () {
          ref.read(colorSettingsProvider.notifier).select(color);
        },
        radius: 22,
        autofocus: color.value == selected.value,
        child: CircleAvatar(
          backgroundColor: color,
          radius: 15,
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(colorSettingsProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors
          .map(
            (color) => renderColorSelector(color, selected, ref),
          )
          .toList(),
    );
  }
}
