import 'package:material_ui/material_ui.dart';

class WeButton extends StatefulWidget {
  const WeButton({
    super.key, 
    this.color = Colors.red, 
    this.borderRadius = .zero, 
    this.border,
    this.child = const SizedBox.shrink(),
    this.padding = .zero,
    this.callback,
    this.height,
    this.width,
  });

  final Color color;
  final Border? border;
  final BorderRadius borderRadius;
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? callback;
  final double? width;
  final double? height;

  @override
  State<WeButton> createState() => _state();

}

class _state extends State<WeButton> {
  final ValueNotifier<bool> isActive = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isActive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeState = _MyButtomTweenStyle(
      color: widget.color.withAlpha(128)
    );
    final inactiveState = _MyButtomTweenStyle(
      color: widget.color
    );
    

    return RepaintBoundary(
      child: MouseRegion(
      onEnter: (event) => isActive.value = true,
      onExit: (event) => isActive.value = false,
      child: GestureDetector(
        onTap: () => widget.callback?.call(),
        child: ValueListenableBuilder<bool>(
          valueListenable: isActive, 
          builder: (context, value, child) {
            return TweenAnimationBuilder(
              tween: _MyButtomTween(end: value ? activeState : inactiveState), 
              duration: const Duration(milliseconds: 300), 
              builder: (context, value, child) {
                return Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: value.color,
                    border: widget.border,
                    borderRadius: widget.borderRadius,
                  ),
                  child: child,
                );
              },
              child: child,
            );
          },
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      )
    ),
    );
  }
}

class _MyButtomTweenStyle {
  final Color color;
  const _MyButtomTweenStyle({required this.color});

  static _MyButtomTweenStyle lerp(_MyButtomTweenStyle a, _MyButtomTweenStyle b, double t) {
    return _MyButtomTweenStyle(color: Color.lerp(a.color, b.color, t)!);
  }
}

class _MyButtomTween extends Tween<_MyButtomTweenStyle> {
  _MyButtomTween({super.begin, super.end});

  @override
  _MyButtomTweenStyle lerp(double t) {
    return _MyButtomTweenStyle.lerp(begin!,end!,t);
  }

}
