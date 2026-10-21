import 'syntax_tree.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';

class TableAliasing {
  const TableAliasing(this.tableName, this.aliasing);

  final String tableName;
  final String aliasing;

  @override
  String toString() => 
      'TableAliasing(tableName: $tableName, aliasing: $aliasing)';
}

class FromStatementNode {
  final List<String> tables;

  FromStatementNode({
    required this.tables,
  });

  @override
  List<MyTable> tablesSearch(MyDB database) {
    final List<MyTable> res = [];
    for (int i = 0 ; i < tables.length ; i++) {
      final isContain = database.contain(tables[i]);
      if (!isContain.contain) throw MySQLErrorNotFound(tables[i]);
      res.add(database.tables[isContain.index!]);
    }
    return res;
  }

  @override
  String toString() => 
      'FromStatementNode(tables: $tables)';
}