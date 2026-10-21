import 'package:flutter/material.dart';

class WeDropMenuItem {
  final String text;
  final VoidCallback? onTap;

  const WeDropMenuItem({required this.text, this.onTap});
}

class WeDropMenu extends StatelessWidget {
  final Widget child;
  final List<WeDropMenuItem> items;
  final double maxHeight;
  final double width;
  final BorderRadius borderRadius;
  final Border? border;
  final Color? backgroundColor;
  final Color? colorText;

  const WeDropMenu({
    super.key,
    required this.child,
    required this.items,
    this.maxHeight = 240,
    this.width = 350,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.border,
    this.backgroundColor,
    this.colorText,
  });

  Future<void> _open(BuildContext context) async {
    //print("rabotai");
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject() as RenderBox;

    final buttonTopRight = box.localToGlobal(Offset(-width + 72, 0), ancestor: overlayBox);
    final buttonSize = box.size;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => entry.remove(),
              ),
            ),
            Positioned(
              left: buttonTopRight.dx,
              top: buttonTopRight.dy + buttonSize.height + 4,
              width: width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Theme.of(context).colorScheme.surface,
                    border: border,
                    borderRadius: borderRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (items.isEmpty) SizedBox(
                          width: .infinity,
                          height: 64,
                          child: Align(
                            alignment: .center,
                            child: Text(
                              "Ничего нету(",
                              textAlign: .center,
                              style: TextStyle(
                                color: colorText
                              ),
                            ),
                          )
                        ),
                        for (final item in items)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              entry.remove();
                              item.onTap?.call();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  item.text,
                                  textAlign: .center,
                                  style: TextStyle(
                                    color: colorText
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: child,
    );
  }
}