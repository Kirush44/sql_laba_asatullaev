import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/binary_node.dart';

import 'syntax_tree.dart';
import 'foreign_key_node.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';

class UpdateStatementNode extends ASTNode {
  final String tableName;
  final List<({String columnName, String data})> columnsWithData;
  final ExpressionNode? whereClause;

  UpdateStatementNode({required this.tableName, required this.columnsWithData, this.whereClause});

  @override
  MyDB invoke(MyDB database) {

    final isContain = database.contain(tableName);
    if (!isContain.contain) throw MySQLErrorNotFound(tableName);
    MyTable table = database.tables[isContain.index!];

    List<List<MyCellData>> data = [];

    if (whereClause == null) {
      table = table.copyWith(dataset: const []);
    } else {

      for (int i = 0; i < table.dataset.length; i++) {
        final row = table.dataset[i];

        if (whereClause != null) {
          bool isMatch = whereClause!.evaluate(row, table.names);
          if (!isMatch) {
            continue; 
          }
        }
        List<MyCellData> selectedRow = [];
        for (int j = 0 ; j < table.names.length ; j++) {
          for (int k = 0 ; k < columnsWithData.length ; k++) {
            if (table.names[j].name.toLowerCase() == columnsWithData[k].columnName) {
              final newRow = MyCellData.factory(table.names[j].type, columnsWithData[k].data);
              ////print("$runtimeType -> newRow $newRow");
              ////print("$runtimeType -> ${table.names[j].name} ${table.names[j].isUnique}");
              if (table.names[j].isUnique && List.generate(table.dataset.length, (m) => table.dataset[m][j].value).toSet().contains(newRow.value)) {
                throw MySQLErrorIsUnique("${newRow.value}", table.names[j].name);
              }
              row[j] = newRow;
              break;
            }
          }
          selectedRow.add(row[j]);
        }
        data.add(selectedRow);
      }
      table = table.copyWith(dataset: data);
      ////print("$runtimeType -> $data");
    }

    return database;
  }

  @override
  String toString() => 'UpdateStatementNode(table: $tableName, columnsWithData: $columnsWithData, whereClause: $whereClause)';
}