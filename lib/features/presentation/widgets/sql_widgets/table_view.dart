import 'package:material_ui/material_ui.dart';
import 'package:fake_sql/features/data/entity/table_entity.dart';

class _TableLayout {
  final List<double> columnWidths;
  final double rowHeight;
  final List<String> headerNames;

  const _TableLayout({
    required this.columnWidths,
    required this.rowHeight,
    required this.headerNames,
  });

  double get idColumnWidth => columnWidths[0];

  factory _TableLayout.compute({
    required MyTable table,
    required TextStyle textStyle,
    required EdgeInsets paddingCell,
    required double spacing,
  }) {
    final maxValues = List<String>.generate(
      table.names.length,
      (i) => table.names[i].name,
    );
    for (final row in table.dataset) {
      for (var j = 0; j < row.length && j < maxValues.length; j++) {
        final s = '${row[j].value}';
        if (s.length > maxValues[j].length) maxValues[j] = s;
      }
    }

    final idPainter = TextPainter(
      text: TextSpan(text: '${table.dataset.length}', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final widths = <double>[idPainter.width + paddingCell.horizontal + 5];
    double rowHeight = idPainter.height + paddingCell.vertical;

    for (var i = 0; i < maxValues.length; i++) {
      final p = TextPainter(
        text: TextSpan(text: maxValues[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final extra = (i == maxValues.length - 1) ? 5.0 : spacing;
      widths.add(p.width + paddingCell.horizontal + extra);

      final cellHeight = p.height + paddingCell.vertical;
      if (cellHeight > rowHeight) rowHeight = cellHeight;
    }

    return _TableLayout(
      columnWidths: widths,
      rowHeight: rowHeight,
      headerNames: ['', ...table.names.map((n) => n.name)],
    );
  }
}

class WeTableView extends StatefulWidget {
  const WeTableView({
    super.key,
    required this.table,
    this.paddingCell = const EdgeInsets.all(6),
    this.divider = 1,
    this.colorDivider = Colors.red,
    this.spacing = 32,
    this.colorRowId,
    this.colorRowPrimary,
    this.colorRowSecondary,
    this.textStyle = const TextStyle(),
  });

  final MyTable? table;
  final EdgeInsets paddingCell;
  final double divider;
  final Color colorDivider;
  final double spacing;
  final Color? colorRowId;
  final Color? colorRowPrimary;
  final Color? colorRowSecondary;
  final TextStyle textStyle;

  @override
  State<WeTableView> createState() => _WeTableViewState();
}

class _WeTableViewState extends State<WeTableView> {
  _TableLayout? _layout;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void didUpdateWidget(covariant WeTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.table, widget.table) ||
        oldWidget.textStyle != widget.textStyle ||
        oldWidget.paddingCell != widget.paddingCell ||
        oldWidget.spacing != widget.spacing) {
      _recompute();
    }
  }

  void _recompute() {
    if (widget.table == null) {
      _layout = null;
      return;
    }
    _layout = _TableLayout.compute(
      table: widget.table!,
      textStyle: widget.textStyle,
      paddingCell: widget.paddingCell,
      spacing: widget.spacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final table = widget.table;
    final layout = _layout;

    if (table == null || layout == null) {
      return Align(
        alignment: Alignment.center,
        child: Text("Ничего нету(", style: widget.textStyle),
      );
    }

    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: GlobalMaterialLocalizations.delegates,
      child: Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, con) {
          return SizedBox(
            width: con.maxWidth,
            child: SelectionArea(
              child: ListView.builder(
                itemCount: table.dataset.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeader(layout);
                  }
                  final rowIndex = index - 1;
                  return _buildRow(layout, table, rowIndex);
                },
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildHeader(_TableLayout layout) {
    return _buildRowFromValues(
      layout: layout,
      values: layout.headerNames,
      backgroundColor: null,
      idColor: null,
    );
  }

  Widget _buildRow(_TableLayout layout, MyTable table, int rowIndex) {
    final row = table.dataset[rowIndex];
    final values = <String>[
      '$rowIndex',
      for (var j = 0; j < row.length; j++) '${row[j].value}',
    ];
    return _buildRowFromValues(
      layout: layout,
      values: values,
      backgroundColor: rowIndex % 2 == 0
          ? widget.colorRowPrimary
          : widget.colorRowSecondary,
      idColor: widget.colorRowId,
    );
  }

  Widget _buildRowFromValues({
    required _TableLayout layout,
    required List<String> values,
    required Color? backgroundColor,
    required Color? idColor,
  }) {
    return RepaintBoundary(
      child: Container(
        color: backgroundColor,
        height: layout.rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: layout.idColumnWidth,
              color: idColor,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: widget.paddingCell.left),
              child: Text(
                values.isNotEmpty ? values[0] : '',
                style: widget.textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (var i = 1; i < layout.columnWidths.length; i++)
              SizedBox(
                width: layout.columnWidths[i],
                child: Padding(
                  padding: EdgeInsets.only(left: widget.paddingCell.left),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      i < values.length ? values[i] : '',
                      style: widget.textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}