import 'syntax_tree.dart';
import 'binary_node.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';
import 'from_node.dart';

class SelectStatementNode extends ASTNode {
  final List<String> columns;
  final FromStatementNode fromClause;
  final ExpressionNode? whereClause;

  SelectStatementNode({
    required this.columns,
    required this.fromClause,
    this.whereClause,
  });

  @override
  MyDB invoke(MyDB database) {

    final MyTable _table = fromClause.tablesSearch(database)[0];

    List<int> colsIndex = [];
    List<MyColumnSettings> cols = [];
    
    if (columns.length == 1 && columns[0] == "*") {
      colsIndex = List.generate(_table.names.length, (i) => i);
      cols = _table.names;
    } else {
      for (int i = 0; i < _table.names.length; i++) {
        if (columns.any((c) => c.toLowerCase() == _table.names[i].name.toLowerCase())) {
          colsIndex.add(i);
          cols.add(_table.names[i]);
        }
      }
    }

    List<List<MyCellData>> data = [];

    for (int i = 0; i < _table.dataset.length; i++) {
      final row = _table.dataset[i];

      if (whereClause != null) {
        bool isMatch = whereClause!.evaluate(row, _table.names);
        if (!isMatch) {
          continue; 
        }
      }

      List<MyCellData> selectedRow = [];
      for (int j in colsIndex) {
        selectedRow.add(row[j]);
      }
      data.add(selectedRow);
    }

    ////print("SelectStatementNode -> invoke -> ${data.length}");
    
    final db = MyDB([MyTable(dataset: data, names: cols, nameTable: "Результат")]);
    return db;
  }

  @override
  String toString() => 
      'SelectStatementNode(columns: $columns, fromClause: $fromClause, where: $whereClause)';
}