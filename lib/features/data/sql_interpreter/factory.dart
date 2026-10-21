import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import 'package:fake_sql/features/data/sql_interpreter/main.dart';
import 'package:fake_sql/features/data/sql_interpreter/statement_node_parse/export_parse.dart';
import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/syntax_tree.dart';
import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/update_node.dart';
import 'package:flutter/foundation.dart';
import '../sql_interpreter/statement_node_parse/export_parse.dart';

class MyNodeFactory {
  final List<String> tokens;
  const MyNodeFactory(this.tokens);

  Future<ASTNode> adjust() async {
    switch (tokens[0]) {
      case 'select': return await Future.microtask(() => StatementSelectNodeParse.parseSelect(tokens));
      case 'create': return StatementCreateTableNodeParse.parseCreateTable(tokens);
      case 'delete': return StatementDeleteFromNodeParse.parseDeleteFromTable(tokens);
      case 'drop': return StatementDropTableNodeParse.parseDropTable(tokens);
      case 'insert': return await StatementInsertIntoNodeParse.parseInsertInto(tokens);
      case 'update': return StatementUpdateNodeParse.parseUpdate(tokens);
      default: throw MySQLErrorSyntax(tokens.isNotEmpty ? tokens[0]  : 'пусто');
    }
  }
}