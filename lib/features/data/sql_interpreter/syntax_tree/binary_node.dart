import 'syntax_tree.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';

sealed class ExpressionNode {
  /// Универсальный метод для проверки строки данных по условию
  bool evaluate(List<MyCellData> row, List<MyColumnSettings> columns);
}

class BinaryOpNode extends ExpressionNode {
  final String left;
  final String operator;
  final String right;

  BinaryOpNode({
    required this.left,
    required this.operator,
    required this.right,
  });

  dynamic parseRight(EnumCellData type) {
    final value = MyCellData.factory(type, right).value;
    ////print("$runtimeType -> $right $value $type");
    return value;
  }

  bool more(dynamic a, dynamic b) => a > b;
  bool moreOrEaquel(dynamic a, dynamic b) => a >= b;
  bool eaquel(dynamic a, dynamic b) => a == b;
  bool less(dynamic a, dynamic b) => a < b;
  bool lessOrEaquel(dynamic a, dynamic b) => a <= b;
  bool notEaquel(dynamic a, dynamic b) => a != b;

  bool Function(dynamic a, dynamic b) operatorFactory() {
    if (operator == ">") return more;
    if (operator == ">=") return moreOrEaquel;
    if (operator == "=") return eaquel;
    if (operator == "<") return less;
    if (operator == "<=") return lessOrEaquel;
    if (operator == "!=") return notEaquel;
    throw MySQLErrorSyntax(operator);
  }

  @override
  bool evaluate(List<MyCellData> row, List<MyColumnSettings> columns) {
    int? columnIndex;
    for (int i = 0; i < columns.length; i++) {
      if (left.toLowerCase() == columns[i].name.toLowerCase()) {
        columnIndex = i;
        break;
      }
    }

    if (columnIndex == null) throw MySQLErrorNotFound(left);

    final cellValue = row[columnIndex].value;
    final parsedSource = parseRight(columns[columnIndex].type);
    ///чеза бред
    ////print("$runtimeType -> $cellValue ${cellValue.runtimeType} == $parsedSource ${parsedSource.runtimeType} ${cellValue == parsedSource}");
    final op = operatorFactory();

    return op.call(cellValue, parsedSource);
  }

  /// Метод фильтрации всей таблицы
  MyTable filter({required MyTable table}) {
    final op = operatorFactory();
    
    List<List<MyCellData>> data = [];
    for (int i = 0; i < table.dataset.length; i++) {
      if (evaluate(table.dataset[i], table.names)) {
        data.add(table.dataset[i]);
      }
    }

    return table.copyWith(dataset: data);
  }

  @override
  String toString() => 'BinaryOpNode($left $operator $right)';
}


class OrMultiBinaryOpNode extends ExpressionNode {
  final List<AndMultiBinaryOpNode> multiBinary;

  OrMultiBinaryOpNode({
    required this.multiBinary,
  });

  @override
  bool evaluate(List<MyCellData> row, List<MyColumnSettings> columns) {
    if (multiBinary.isEmpty) return true;

    // OR возвращает трушку если хотя б один AND трушка
    return multiBinary.any((andNode) => andNode.evaluate(row, columns));
  }
  
  @override
  String toString() => 'OrMultiBinaryOpNode(AndMultiBinaryOpNode: $multiBinary)';
}


class AndMultiBinaryOpNode extends ExpressionNode {
  final List<ExpressionNode> multiBinary;

  AndMultiBinaryOpNode({
    required this.multiBinary,
  });

  @override
  bool evaluate(List<MyCellData> row, List<MyColumnSettings> columns) {
    return multiBinary.every((node) => node.evaluate(row, columns));
  }
  
  @override
  String toString() => 'AndMultiBinaryOpNode(multiBinary: $multiBinary)';
}