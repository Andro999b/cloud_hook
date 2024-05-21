import 'package:cloud_hook/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const maxImageWidth = 320.0;

class HorizontalListCard extends HookWidget {
  final GestureTapCallback onTap;
  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Decoration? decoration;
  final Widget? child;
  final Widget? corner;
  final bool autofocus;

  const HorizontalListCard({
    super.key,
    required this.onTap,
    this.onHover,
    this.onLongPress,
    this.decoration,
    this.child,
    this.corner,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);

    var imageWidth =
        isMobile(context) ? MediaQuery.of(context).size.width * .45 : 200.0;

    if (imageWidth > maxImageWidth) {
      imageWidth = maxImageWidth;
    }

    final imageHeight = imageWidth * 1.5;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: focused.value ? 5 : 1,
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: imageHeight,
              maxWidth: imageWidth,
            ),
            decoration: decoration,
            child: SizedBox.expand(child: child),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                autofocus: autofocus,
                mouseCursor: SystemMouseCursors.click,
                onTap: onTap,
                onHover: onHover,
                onLongPress: onLongPress,
                onFocusChange: (value) => focused.value = value,
                child: corner != null
                    ? Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: corner,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
