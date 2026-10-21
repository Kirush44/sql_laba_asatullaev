
import 'package:fake_sql/features/data/sql_interpreter/factory.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';

import 'statement_node_parse/export_parse.dart';
import 'syntax_tree/syntax_tree.dart';

class TextParser {
  String _text;
  List<String> lines = [];

  TextParser(this._text);

  List<String> process() {
    toLower()
        .normalizeSpecialCharacters()
        .splitIntoLines();
    return lines;
  }

  TextParser toLower() {

    _text = _text.toLowerCase();
    return this;
  }

  TextParser normalizeSpecialCharacters() {
    _text = _text.replaceAll(RegExp(r'[ \t]+'), ' ');
    
    _text = _text.replaceAll(RegExp(r'[^\w\s\n]'), '');
    
    _text = _text.trim();
    return this;
  }

  TextParser splitIntoLines() {
    List<String> rawLines = _text.split('\n');
    lines = rawLines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return this;
  }
}

class SqlParser {
  static String _normalizeSpecialCharacters(String text) {
    text = text.replaceAll(RegExp(r'[ \t\n]+'), ' ');

    text = text.replaceAll(',', ' , ');
    text = text.replaceAll('(', ' ( ');
    text = text.replaceAll(')', ' ) ');
    
    text = text.replaceAll(RegExp(r'[^\w\s*<>=,()]'), ' ');
    return text.trim();
  }

  static List<String> _tokenize(String text) {
    List<String> rawTokens = text.split(' ');
    return rawTokens
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList();
  }
  

  // Главный метод-пайплайн
  static Future<ASTNode> parse(String sql) async {
    sql = sql.toLowerCase();
    sql = _normalizeSpecialCharacters(sql);
    List<String> tokens = _tokenize(sql);

    if (tokens.isEmpty) {
      throw MySQLErrorSyntax("Пустой запрос");
    }

    

    return await MyNodeFactory(tokens).adjust();
  }

}




