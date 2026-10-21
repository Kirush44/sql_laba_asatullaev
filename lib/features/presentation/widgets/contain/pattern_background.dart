import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';

class WeDotGridBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color dotColor;
  final double spacingMultiplier;
  final double zoomMax;
  final double zoomMin;

  const WeDotGridBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFCC0000),
    this.dotColor = Colors.white,
    this.spacingMultiplier = 15,
    this.zoomMax = 10,
    this.zoomMin = 0.5
  });

  @override
  State<WeDotGridBackground> createState() => _state();
}

class _state extends State<WeDotGridBackground> {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier<Offset>(Offset.zero);

  static const double _baseRadius = 1;
  static const double _spacingMultiplier = 15.0;
  static const double _minZoom = 0.25;
  static const double _maxZoom = 5;
  static const double _boundaryLimit = 2000.0;

  @override
  void dispose() {
    _scaleNotifier.dispose();
    _offsetNotifier.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final currentScale = _scaleNotifier.value;
      final currentOffset = _offsetNotifier.value;

      final zoomFactor = event.scrollDelta.dy < 0 ? 1.15 : 0.87;
      final newScale = (currentScale * zoomFactor).clamp(_minZoom, _maxZoom);

      if (newScale == currentScale) return;

      final focalPoint = event.localPosition;
      final newOffset = focalPoint - (focalPoint - currentOffset) * (newScale / currentScale);

      _scaleNotifier.value = newScale;
      _offsetNotifier.value = Offset(
        newOffset.dx.clamp(-_boundaryLimit, _boundaryLimit),
        newOffset.dy.clamp(-_boundaryLimit, _boundaryLimit),
      );
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final currentOffset = _offsetNotifier.value;
    final newOffset = currentOffset + details.delta;
    
    _offsetNotifier.value = Offset(
      newOffset.dx.clamp(-_boundaryLimit, _boundaryLimit),
      newOffset.dy.clamp(-_boundaryLimit, _boundaryLimit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Focus(
        autofocus: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.allScroll,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: _handlePanUpdate,
                      child: ValueListenableBuilder<double>(
                        valueListenable: _scaleNotifier,
                        builder: (context, scale, _) {
                          return ValueListenableBuilder<Offset>(
                            valueListenable: _offsetNotifier,
                            builder: (context, offset, __) {
                              return CustomPaint(
                                painter: _DotGridPainter(
                                  scale: scale,
                                  offset: offset,
                                  backgroundColor: widget.backgroundColor,
                                  dotColor: widget.dotColor,
                                  baseRadius: _baseRadius,
                                  baseSpacing: _baseRadius * _spacingMultiplier,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  
                  Positioned.fill(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scaleNotifier,
                      builder: (context, scale, _) {
                        return ValueListenableBuilder<Offset>(
                          valueListenable: _offsetNotifier,
                          builder: (context, offset, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..translate(offset.dx, offset.dy)
                                ..scale(scale),
                              child: child,
                            );
                          },
                          child: Align(
                            child: widget.child,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _DotGridPainter extends CustomPainter {
  final double scale;
  final Offset offset;
  final Color backgroundColor;
  final Color dotColor;
  final double baseRadius;
  final double baseSpacing;

  _DotGridPainter({
    required this.scale,
    required this.offset,
    required this.backgroundColor,
    required this.dotColor,
    required this.baseRadius,
    required this.baseSpacing,
  });

  @override
  void paint(Canvas sizeCanvas, Size size) {
    // 1. Рисуем фон
    final paintBg = Paint()..color = backgroundColor;
    sizeCanvas.drawRect(Offset.zero & size, paintBg);

    final spacing = baseSpacing * scale;
    final radius = baseRadius * scale;

    if (radius < 0.1) return; // Слишком мелко, не рисуем

    final paintDot = Paint()
      ..color = dotColor
      ..strokeWidth = radius * 2 // Толщина точки для режима точек
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startX = offset.dx % spacing;
    final startY = offset.dy % spacing;

    // Сбор координат точек в один массив для пакетной отправки на GPU
    final List<Offset> points = [];

    for (double x = startX - spacing; x < size.width + spacing; x += spacing) {
      for (double y = startY - spacing; y < size.height + spacing; y += spacing) {
        points.add(Offset(x, y));
      }
    }

    // РЕНДЕРИНГ ВСЕХ ТОЧКЕ ЗА ОДИН ВЫЗОВ (GPU Batching)
    // Это заменяет тысячи вызовов drawCircle и моментально поднимает FPS до 60/120.
    if (points.isNotEmpty) {
      sizeCanvas.drawPoints(.points, points, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dotColor != dotColor;
  }
}