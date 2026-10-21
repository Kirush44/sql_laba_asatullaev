import 'package:fake_sql/app/export/flutter.dart';
import 'buttons.dart';

class WeScreenCard extends StatelessWidget {
  final EdgeInsets padding;
  final Color color;
  final Widget? child;
  final Widget? childBetweenButtons;
  final List<Widget> topButtons;
  final List<Widget> bottomButtons;
  const WeScreenCard({
    super.key,
    this.padding = .zero,
    this.color = Colors.green,
    this.child,
    this.childBetweenButtons,
    this.topButtons = const [],
    this.bottomButtons = const [],
  });


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: color)),
          if (child != null) child!,
          Positioned.fill(
            child: Column(
              mainAxisAlignment: .spaceBetween,
              mainAxisSize: .max,
              children: [
                if (topButtons.isNotEmpty) Padding(
                  padding: padding,
                  child: SingleChildScrollView(child: Row(spacing: 12,children: topButtons)),
                ) else const SizedBox.shrink(),
                if (childBetweenButtons != null) Expanded(
                  child: childBetweenButtons!,
                  ///childBetweenButtons!,
                ),
                if (bottomButtons.isNotEmpty) Align(
                  alignment: .bottomLeft,
                  child: Padding(
                  padding: padding,
                  child: SingleChildScrollView(child: Row(spacing: 12,children: bottomButtons)),
                ),
                )
              ],
            ),
          ),
          
        ],
      );
  }
}