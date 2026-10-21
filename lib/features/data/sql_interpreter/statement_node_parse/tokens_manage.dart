import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import '../syntax_tree/export_nodes.dart';
import 'where_clause.dart';


class TokensManager {
  TokensManager(this.tokens);

  final List<String> tokens;

  int position = 0;

  String get current => position < tokens.length ? tokens[position] : '';

  String currentShift(int shift) => position + shift < tokens.length ? tokens[position + shift] : '';

  String consume([String? expected]) {
    final token = current;
    if (expected != null && token.toLowerCase() != expected.toLowerCase()) {
      throw MySQLErrorUnexpectedSysnax(expected, token);
    }
    position++;
    return token;
  }
  String? consumeOptional([String? expected]) {
    if (current == expected) return consume(expected);
    return null;
  }

  List<String> multiConsume([List<String> expected = const []]) {
    List<String> res = [];
    for (String s in expected) {
      res.add(consume(s));
    }
    return res;
  }

  void pipelineDivision({void Function()? ifRoad, void Function()? elseRoad, List<String> expected = const []}) {
    bool isElseRoad = false;

    for (int i = 0 ; i < expected.length ; i++) {
      if (expected[i] != currentShift(i)) {
        elseRoad?.call();
        isElseRoad = true;
        break;
      }
    }

    if (!isElseRoad) {
      for (int i = 0 ; i < expected.length ; i++) {consume();}
      ifRoad?.call();
    }
    
  }

  void pipelineMultiDivision({
    List<({List<String> expected, void Function()? ifRoad})> roads = const [],
    void Function()? elseRoad, 
  }) {
    bool isAnyRoadExists = false;

    for (final r in roads) {
      pipelineDivision(
        expected: r.expected, 
        ifRoad: () {
          isAnyRoadExists = true;
          r.ifRoad?.call();
        }, 
        elseRoad: () => isAnyRoadExists = false
      );
    }
    if (!isAnyRoadExists) elseRoad?.call();
  }

  void pipelineWhile({required void Function() cycle, String? current}) {
    while (this.current.isNotEmpty && this.current != current) {
      cycle.call();
    }
  }


  ExpressionNode? whereClause() {
    if (current == 'where') {
      consume('where');
      WhereClause whereClause = WhereClause(this);
      final node = whereClause.parse();
      //print(whereClause);
      return node;
    }
  }



  ///Оптимизация реал нужна
  Future<void> chuncksDelayed() async {
    if (position % 10 == 0) await Future.delayed(Duration.zero);
  }

  void log() => 67; //print("TokensManager -> log: ${currentShift(-3)} ${currentShift(-2)} ${currentShift(-1)} ${currentShift(0)}");

}