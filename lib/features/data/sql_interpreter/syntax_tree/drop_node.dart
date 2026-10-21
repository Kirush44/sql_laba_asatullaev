import 'syntax_tree.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../../entity/export_database.dart';


class DropTableStatementNode extends ASTNode {
  final String nameTable;
  final bool ifExists;

  DropTableStatementNode({
    required this.nameTable,
    this.ifExists = false,
  });

  @override
  MyDB invoke(MyDB database) {
    final isContain = database.contain(nameTable);
    if (!isContain.contain && ifExists) return database;
    if (!isContain.contain && !ifExists) throw MySQLErrorNotFound(nameTable);
    final res = database.copyWith(tables: database.tables..removeAt(isContain.index!));
    return res;
  }

  @override
  String toString() => 
      'DropTableStatementNode(nameTable: $nameTable, idExist: $ifExists)';
}