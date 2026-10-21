import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';


extension StatementDeleteFromNodeParse on SqlParser {

  static ASTNode parseDeleteFromTable(List<String> tokens) {
    final mg = TokensManager(tokens);

    mg.multiConsume(['delete','from']);

    final tableName = mg.consume();

    final whereClause = mg.whereClause();

    return DeleteFromTableStatementNode(fromClause: FromStatementNode(tables: [tableName]), whereClause: whereClause);
  }
}