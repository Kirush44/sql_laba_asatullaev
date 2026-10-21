import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../../data/entity/export_database.dart';

class WeTableCard extends StatelessWidget {
  const WeTableCard({
    super.key,
    required this.table,
    this.textStyle,
    this.borderRadius = const .all(.circular(12)),
    this.padding = const .all(6),
    this.border,
    this.color = Colors.black,
    this.colorHeader = Colors.grey,
    this.colorMainText = Colors.white,
    this.colorText = Colors.grey,
    this.spacing = 24,
    this.state = const WeTableCardTweenStyle(
      offset: .zero, 
      colorShadow: Colors.black26, 
      spreadRadius: 2
    )
  });

  final WeTableCardTweenStyle state;

  final MyTable table;
  final double spacing;

  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Border? border;

  final Color colorHeader;
  final Color color;
  final Color colorMainText;
  final Color colorText;
  final TextStyle? textStyle;

  String maxRowTableString(List<({String name, String type})> list) {
    String max = "";
    for (int i = 0 ; i < list.length ; i++) {
      final String str = list[i].name + list[i].type.toUpperCase();
      if (str.length > max.length) max = str;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final tableData = table.namesWithTypeName;
    final maxRow = maxRowTableString(tableData);

    final linePainter = TextPainter(
        text: TextSpan(text: maxRow, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

    final maxWidth = linePainter.width + padding.horizontal + spacing + padding.left + 14;

    return TweenAnimationBuilder(
      tween: _WeTableCardTween(end: state), 
      duration: const Duration(milliseconds: 200), 
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: maxWidth,
          transform: Matrix4.translationValues(value.offset.dx, value.offset.dy, 0),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: border,
            color: color,
            boxShadow: [
              BoxShadow(color: value.colorShadow, blurRadius: 3, spreadRadius: value.spreadRadius, offset: value.offset)
            ]
          ),
          child: child
        );
      },
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Container(
            width: .infinity,
            decoration: BoxDecoration(
              borderRadius: .only(topLeft: borderRadius.topLeft, topRight: borderRadius.topRight),
              color: colorHeader,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: padding.top,
                right: padding.right,
                bottom: padding.bottom / 2,
                left: padding.left * 2 + 14
              ),
              child: Text(table.nameTable, style: textStyle?.copyWith(color: colorMainText) ?? .new(color: colorMainText)),
            ),
          ),
          Container(
            color: border?.bottom.color ?? Colors.green,
            height: border?.bottom.width ?? 1.5,
            width: .infinity,
          ),
          Padding(
            padding: padding,
            child: Column(
              children: [
                for (int i = 0 ; i < tableData.length ; i++) Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      spacing: padding.right,
                      children: [
                        if (table.names[i].isPrimaryKey) Icon(Icons.key, size: 14, color: Colors.redAccent,)
                        else SizedBox(width: 14,),
                        Text(
                          tableData[i].name.toLowerCase(), 
                          style: textStyle?.copyWith(color: colorMainText) ?? .new(color: colorMainText)
                        ), 
                      ],
                    ),
                    Text(
                      tableData[i].type.toUpperCase(), 
                      style: textStyle?.copyWith(color: colorText) ?? .new(color: colorText)
                    ),
                  ],
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

class WeTableCardTweenStyle {
  final Offset offset;
  final Color colorShadow;
  final double spreadRadius;

  const WeTableCardTweenStyle({required this.offset, required this.colorShadow, required this.spreadRadius});
}

class _WeTableCardTween extends Tween<WeTableCardTweenStyle> {
  _WeTableCardTween({super.begin, super.end});

  @override
  WeTableCardTweenStyle lerp(double t) {
    return WeTableCardTweenStyle(
      offset: Offset.lerp(begin!.offset, end!.offset, t)!,
      colorShadow: Color.lerp(begin!.colorShadow, end!.colorShadow, t)!,
      spreadRadius: lerpDouble(begin!.spreadRadius, end!.spreadRadius, t)!
    );
  }
}