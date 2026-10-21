import 'package:flutter/widgets.dart';
import '../../../data/entity/export_database.dart';
import 'table_card.dart';
import 'package:flutter/material.dart';

class WeDatabaseHolder extends StatefulWidget {
  const WeDatabaseHolder({
    super.key,
    required this.database,
    this.onTap,
    this.textStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(6),
    this.border,
    this.color = Colors.black,
    this.colorHeader = Colors.grey,
    this.colorMainText = Colors.white,
    this.colorText = Colors.grey,
    this.spacing = 24,
  });

  final MyDB database;
  final void Function(MyTable, int)? onTap;

  final double spacing;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Border? border;

  final Color colorHeader;
  final Color color;
  final Color colorMainText;
  final Color colorText;
  final TextStyle? textStyle;

  @override
  State<WeDatabaseHolder> createState() => _state();
}

class _state extends State<WeDatabaseHolder> {
  late List<ValueNotifier<bool>> _hoverNotifiers;

  static const inactive = WeTableCardTweenStyle(
    offset: Offset.zero,
    spreadRadius: 2,
    colorShadow: Colors.black38,
  );

  static const active = WeTableCardTweenStyle(
    offset: Offset(0, 5),
    spreadRadius: 5,
    colorShadow: Colors.black38,
  );

  @override
  void initState() {
    super.initState();
    _initNotifiers();
  }

  void _initNotifiers() {
    _hoverNotifiers = List.generate(
      widget.database.tables.length,
      (_) => ValueNotifier<bool>(false),
    );
  }

  @override
  void didUpdateWidget(covariant WeDatabaseHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.database.tables.length != widget.database.tables.length) {
      for (var notifier in _hoverNotifiers) {
        notifier.dispose();
      }
      _initNotifiers();
    }
  }

  @override
  void dispose() {
    for (var notifier in _hoverNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < widget.database.tables.length; i++)
          Positioned(
            left: i * 200,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (e) => _hoverNotifiers[i].value = true,
              onExit: (e) => _hoverNotifiers[i].value = false,
              child: GestureDetector(
                onTap: () => widget.onTap?.call(widget.database.tables[i], i),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _hoverNotifiers[i],
                  builder: (context, isActive, child) {
                    return WeTableCard(
                      state: isActive ? active : inactive,
                      spacing: widget.spacing,
                      borderRadius: widget.borderRadius,
                      padding: widget.padding,
                      border: widget.border,
                      colorHeader: widget.colorHeader,
                      color: widget.color,
                      colorMainText: widget.colorMainText,
                      colorText: widget.colorText,
                      textStyle: widget.textStyle,
                      table: widget.database.tables[i],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}