import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/update_node.dart';

import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';

extension StatementUpdateNodeParse on SqlParser {
  static ASTNode parseUpdate(List<String> tokens) {
    final mg = TokensManager(tokens);

    mg.consume('update');

    final tableName = mg.consume();

    mg.consume('set');

    List<({String columnName, String data})> columnsWithData = [];

    mg.pipelineWhile(
      current: "where",
      cycle: () {
        final columnName = mg.consume();
        mg.consume('=');
        final columnData = mg.consume();
        columnsWithData.add((columnName: columnName, data: columnData));
        mg.consumeOptional(',');
      }
    );

    final whereClause = mg.whereClause();

    return UpdateStatementNode(tableName: tableName, columnsWithData: columnsWithData, whereClause: whereClause);
  }
}