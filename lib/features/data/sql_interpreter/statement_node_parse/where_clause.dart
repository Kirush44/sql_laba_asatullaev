import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import 'package:fake_sql/features/data/sql_interpreter/statement_node_parse/tokens_manage.dart';
import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/binary_node.dart';

class WhereClause {
  WhereClause(this.tokensManager);
  final TokensManager tokensManager;

  OrMultiBinaryOpNode parse() {
    return parseOrExpression();
  }

  OrMultiBinaryOpNode parseOrExpression() {
    List<AndMultiBinaryOpNode> andNodes = [];
    andNodes.add(parseAndExpression());

    while (tokensManager.current.toLowerCase() == 'or') {
      tokensManager.consume();
      andNodes.add(parseAndExpression());
    }

    return OrMultiBinaryOpNode(multiBinary: andNodes);
  }

  AndMultiBinaryOpNode parseAndExpression() {
    List<ExpressionNode> factors = [];
    factors.add(parseFactor());

    while (tokensManager.current.toLowerCase() == 'and') {
      tokensManager.consume();
      factors.add(parseFactor());
    }

    return AndMultiBinaryOpNode(multiBinary: factors);
  }

  ExpressionNode parseFactor() {
    if (tokensManager.current == '(') {
      tokensManager.consume();
      
      final node = parseOrExpression();
      
      if (tokensManager.current != ')') {
        throw MySQLErrorSyntax("Expected ')'");
      }
      tokensManager.consume();
      
      return node;
    } else {
      final left = tokensManager.consume();
      final op = tokensManager.consume();
      final right = tokensManager.consume();
      return BinaryOpNode(left: left, operator: op, right: right);
    }
  }

  @override
  String toString() => "WhereClause(binaries: ${parse()})";
}