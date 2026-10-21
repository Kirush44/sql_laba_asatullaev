import 'syntax_tree.dart';
import 'foreign_key_node.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';

class CreateTableStatementNode extends ASTNode {
  final String tableName;
  final List<MyColumnSettings> columns;
  final List<ForeignKeyStatementNode> foreignKey;

  CreateTableStatementNode({required this.tableName, required this.columns, this.foreignKey = const []});

  @override
  MyDB invoke(MyDB database) {
    if (database.contain(tableName).contain) throw MySQLErrorDontOverlap(tableName);

    List<MyTableConnect> checkedForeignKey = [];

    for (int i = 0 ; i < foreignKey.length; i++) {
      final refTable = database.mapTables[foreignKey[i].referencesNameTable];
      if (refTable == null) throw MySQLErrorNotFound("references ${foreignKey[i].referencesNameTable}");

      final columnFrom = columns.firstWhere((e) => e.name.toLowerCase() == foreignKey[i].keyColumnName.toLowerCase(), orElse: () => throw MySQLErrorNotFound(foreignKey[i].keyColumnName));

      final columnTo = refTable.names.firstWhere((e) => e.name.toLowerCase() == foreignKey[i].referencesColumnName.toLowerCase(), orElse: () => throw MySQLErrorNotFound(foreignKey[i].referencesColumnName));
      
      checkedForeignKey.add(
        MyTableConnect(tableName,columnFrom, toTableName: foreignKey[i].referencesNameTable, columnTo: columnTo)
      );
    }

    final table = MyTable(
      nameTable: tableName,
      dataset: [],
      names: columns,
    );

    return database.copyWith(tables: [...database.tables, table], connects: checkedForeignKey);
  }

  @override
  String toString() => 'CreateTableStatementNode(table: $tableName, columns: $columns, foreignKey: $foreignKey)';
}