import 'syntax_tree.dart';
import 'binary_node.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';
import 'from_node.dart';

class DeleteFromTableStatementNode extends ASTNode {
  final FromStatementNode fromClause;
  final ExpressionNode? whereClause;

  DeleteFromTableStatementNode({required this.fromClause, this.whereClause});

  @override
  MyDB invoke(MyDB database) {

    List<List<MyCellData>> data = [];
    
    MyTable table = fromClause.tablesSearch(database)[0];
    if (whereClause == null) {
      table = table.copyWith(dataset: const []);
    } else {

    final colsIndex = List.generate(table.names.length, (i) => i);

      for (int i = 0; i < table.dataset.length; i++) {
        final row = table.dataset[i];

        if (whereClause != null) {
          bool isMatch = whereClause!.evaluate(row, table.names);
          if (isMatch) {
            continue; 
          }
        }
        List<MyCellData> selectedRow = [];
        for (int j in colsIndex) {
          selectedRow.add(row[j]);
        }
        data.add(selectedRow);
      }
      table = table.copyWith(dataset: data);
      //print("$runtimeType -> $data");
    }
    final db = database;
    final res = db.copyWith(
      tables: List.generate(
        database.tables.length, 
        (i) => database.tables[i].nameTable == table.nameTable
        ? table
        : database.tables[i]
      )
    );
    //print("DeleteFromTableStatementNode -> invoke -> table: $table, database: $database, res: $res");
    return res;
  }

  @override
  String toString() => 'DeleteFromTableStatementNode(fromClause: $fromClause, whereClause: $whereClause)';
}