import 'package:material_ui/material_ui.dart';

class WindowConfig {
  final Widget child;

  const WindowConfig({
    required this.child,
  });
}

class WeMultiWindowLayout extends StatefulWidget {
  final List<List<WindowConfig>> layout;
  final Border? border;
  final BorderRadius borderRadius;
  final double gap;
  final double minWidth;
  final double minHeight;

  final Color colorDivider;

  WeMultiWindowLayout({
    super.key,
    this.border,
    this.borderRadius = .zero,
    this.gap = 20,
    this.minWidth = 200,
    this.minHeight = 200,
    this.colorDivider = Colors.red,
    required this.layout,
  }) : assert(layout.length <= 3, 'Максимум 3 строки'),
        assert(
          !anyRowExceedsColumns(layout, 2),
          'Максимум 2 колонки в строке',
        );

  static bool anyRowExceedsColumns(List<List<WindowConfig>> layout, int maxCols) {
    for (var row in layout) {
      if (row.length > maxCols) return true;
    }
    return false;
  }

  @override
  State<WeMultiWindowLayout> createState() => _state();
}


class _state extends State<WeMultiWindowLayout> {
  late List<double> _rowFlexes;
  late List<List<double>> _colFlexes;

  @override
  void initState() {
    super.initState();
    _initFlexes();
  }

  void _initFlexes() {
    _rowFlexes = List.filled(widget.layout.length, 1.0);
    _colFlexes = widget.layout.map((row) => List.filled(row.length, 1.0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;

        final totalRowGaps = widget.gap * (widget.layout.length - 1);
        final usableHeight = (totalHeight - totalRowGaps).clamp(0.0, double.infinity);
        double totalRowFlex = _rowFlexes.fold(0.0, (a, b) => a + b);

        return Column(
          children: List.generate(widget.layout.length, (rowIndex) {
            final rowFraction = _rowFlexes[rowIndex] / totalRowFlex;
            final rowHeight = usableHeight * rowFraction;

            final rowWidgets = widget.layout[rowIndex];
            final totalColGaps = widget.gap * (rowWidgets.length - 1);
            final usableWidth = (totalWidth - totalColGaps).clamp(0.0, double.infinity);
            double totalColFlex = _colFlexes[rowIndex].fold(0.0, (a, b) => a + b);

            Widget rowContent = Row(
              children: List.generate(rowWidgets.length, (colIndex) {
                final colFraction = _colFlexes[rowIndex][colIndex] / totalColFlex;
                final colWidth = usableWidth * colFraction;

                final config = rowWidgets[colIndex];

                Widget pane = Container(
                  width: colWidth,
                  height: rowHeight,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: widget.border,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: config.child,
                );

                if (colIndex < rowWidgets.length - 1) {
                  return Row(
                    children: [
                      pane,
                      _buildVerticalDivider(rowIndex, colIndex, usableWidth),
                    ],
                  );
                }
                return pane;
              }),
            );

            if (rowIndex < widget.layout.length - 1) {
              return Column(
                children: [
                  SizedBox(height: rowHeight, child: rowContent),
                  _buildHorizontalDivider(rowIndex, usableHeight),
                ],
              );
            }
            return SizedBox(height: rowHeight, child: rowContent);
          }),
        );
      },
    );
  }

  Widget _buildVerticalDivider(int rowIndex, int colIndex, double usableWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            final delta = details.delta.dx / usableWidth;
            final currentCols = _colFlexes[rowIndex];
            
            double leftFlex = currentCols[colIndex] + delta;
            double rightFlex = currentCols[colIndex + 1] - delta;

            if (leftFlex * usableWidth >= widget.minWidth && rightFlex * usableWidth >= widget.minWidth) {
              currentCols[colIndex] = leftFlex;
              currentCols[colIndex + 1] = rightFlex;
            }
          });
        },
        child: SizedBox(
          width: widget.gap,
          child: Center(
            child: Container(
              width: 6,
              height: 36,
              decoration: BoxDecoration(
                color: widget.colorDivider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalDivider(int rowIndex, double usableHeight) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            final delta = details.delta.dy / usableHeight;

            double topFlex = _rowFlexes[rowIndex] + delta;
            double bottomFlex = _rowFlexes[rowIndex + 1] - delta;

            if (topFlex * usableHeight >= widget.minHeight && bottomFlex * usableHeight >= widget.minHeight) {
              _rowFlexes[rowIndex] = topFlex;
              _rowFlexes[rowIndex + 1] = bottomFlex;
            }
          });
        },
        child: SizedBox(
          height: widget.gap,
          child: Center(
            child: Container(
              width: 36,
              height: 6,
              decoration: BoxDecoration(
                color: widget.colorDivider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}