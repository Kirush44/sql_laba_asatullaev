import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';

extension StatementInsertIntoNodeParse on SqlParser {

  static Future<ASTNode> parseInsertInto(List<String> tokens) async {
    final mg = TokensManager(tokens);

    mg.multiConsume(['insert','into']);

    final nameTable = mg.consume();
    //print("parseInsertInto -> $nameTable");

    final List<String> columns = [];

    mg.pipelineDivision(
      expected: ['('],
      ifRoad: () {
        mg.pipelineWhile(
          current: ')',
          cycle: () {
            columns.add(mg.consume());
            mg.consumeOptional(',');
          }
        );
        mg.consume(')');
      }
    );

    mg.consume('values');
    List<List<dynamic>> dataset = []; 

    /// ...) , (...
    mg.pipelineWhile(
      current: ';',
      cycle: () async {
        List<dynamic> rowDataset = [];
        /// (.. , .. , ..)
        mg.consume('(');
        mg.pipelineWhile(
          current: ')' ,
          cycle: () {
            rowDataset.add(mg.consume());
            mg.consumeOptional(',');
          }
        );

        mg.consume(')');
        dataset.add(rowDataset);
        mg.consumeOptional(',');

        await mg.chuncksDelayed();
      }
    );

    return InsertIntoStatementNode(tableName: nameTable, columnNames: columns, insertValues: dataset);
  }
}