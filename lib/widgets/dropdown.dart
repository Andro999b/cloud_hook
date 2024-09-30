import 'package:flutter/material.dart';

typedef AnchorChildBuilder = Function(
  BuildContext context,
  VoidCallback onPressed,
  Widget? child,
);

class Dropdown extends StatefulWidget {
  final List<Widget> menuChildren;
  final AnchorChildBuilder? anchorBuilder;
  final Offset? alignmentOffset;
  final MenuStyle? style;

  @override
  State<Dropdown> createState() => _DropdownState();

  const Dropdown({
    super.key,
    required this.anchorBuilder,
    required this.menuChildren,
    this.alignmentOffset,
    this.style,
  });

  Dropdown.button({
    Key? key,
    required String lable,
    Icon? icon,
    Offset? alignmentOffset,
    MenuStyle? style,
    required List<Widget> menuChildren,
  }) : this(
          key: key,
          anchorBuilder: (context, onPressed, child) => ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(lable),
          ),
          alignmentOffset: alignmentOffset,
          style: style,
          menuChildren: menuChildren,
        );

  Dropdown.iconButton({
    Key? key,
    required Icon icon,
    Offset? alignmentOffset,
    MenuStyle? style,
    required List<Widget> menuChildren,
  }) : this(
          key: key,
          anchorBuilder: (context, onPressed, child) => IconButton(
            onPressed: onPressed,
            icon: icon,
          ),
          alignmentOffset: alignmentOffset,
          style: style,
          menuChildren: menuChildren,
        );
}

class _DropdownState extends State<Dropdown> {
  final _menuControler = MenuController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuControler,
      builder: widget.anchorBuilder == null
          ? null
          : (context, controller, child) {
              final anchorBuilder = widget.anchorBuilder!;
              return anchorBuilder(
                context,
                () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child,
              );
            },
      alignmentOffset: widget.alignmentOffset,
      style: widget.style,
      menuChildren: [
        BackButtonListener(
          onBackButtonPressed: () async {
            _menuControler.close();
            return true;
          },
          child: FocusScope(
            child: Column(
              children: widget.menuChildren,
            ),
          ),
        )
      ],
      consumeOutsideTap: true,
    );
  }
}
