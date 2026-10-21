import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';

extension StatementSelectNodeParse on SqlParser {
  static ASTNode parseSelect(List<String> tokens) {
    final mg = TokensManager(tokens);

    mg.consume('select');

    final columns = <String>[];
    while (mg.current.isNotEmpty && mg.current.toLowerCase() != 'from') {
      columns.add(mg.consume());
      if (mg.current == ',') mg.consume(',');
    }

    mg.consume('from');
    final table = mg.consume();

    final whereClause = mg.whereClause();

    return SelectStatementNode(columns: columns, fromClause: FromStatementNode(tables: [table]), whereClause: whereClause);
  }
}