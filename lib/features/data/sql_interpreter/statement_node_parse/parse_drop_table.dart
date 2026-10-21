import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';
import 'package:fake_sql/features/data/entity/column.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';

extension StatementDropTableNodeParse on SqlParser {

  static ASTNode parseDropTable(List<String> tokens) {
    int position = 0;

    String current() => position < tokens.length ? tokens[position] : '';
    
    String consume([String? expected]) {
      final token = current();
      if (expected != null && token.toLowerCase() != expected.toLowerCase()) {
        throw MySQLErrorUnexpectedSysnax(expected, token);
      }
      position++;
      return token;
    }

    consume('drop');
    consume('table');

    final next = consume();
    if (next != 'if') {
      return DropTableStatementNode(nameTable: next, ifExists: false);
    } else {
      if ("exists" == consume()) {
        return DropTableStatementNode(nameTable: consume(), ifExists: true);
      }
    }

    throw FormatException("Ожидалось 'exists'");
    
  }
}