import '../main.dart';
import '../syntax_tree/export_nodes.dart';
import 'tokens_manage.dart';
import 'package:fake_sql/features/data/entity/column.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';

extension StatementCreateTableNodeParse on SqlParser {
  static ASTNode parseCreateTable(List<String> tokens) {
    final manage = TokensManager(tokens);

    manage.multiConsume(['create','table']);

    final tableName = manage.consume();

    manage.consume('(');

    final List<MyColumnSettings> columns = [];

    List<ForeignKeyStatementNode> foreignKey = [];
    
    while (manage.current.isNotEmpty && manage.current != ')') {

      manage.pipelineDivision(
        expected: ["foreign", "key"],
        ifRoad: () {
          final columnKey = manage.consume();
          manage.consume("references");
          final tableRef = manage.consume();
          manage.consume("(");
          final columnRef = manage.consume();
          manage.consume(")");
          foreignKey.add(ForeignKeyStatementNode(keyColumnName: columnKey, referencesNameTable: tableRef, referencesColumnName: columnRef));
        },
        elseRoad: () {
          final columnName = manage.consume();
          final type = manage.consume();
          final columnType = EnumCellData.getType(type);
          if (columnType == null) {
            manage.log();
            throw MySQLErrorNotFound(type);
          }

          late final bool autoIncrement;

          manage.log();

          manage.pipelineDivision(
            expected: ["auto_increment"],
            ifRoad: () => autoIncrement = true,
            elseRoad: () => autoIncrement = false,
          );

          late final bool isPrimaryKey;

          manage.pipelineDivision(
            expected: ["primary", "key"],
            ifRoad: () => isPrimaryKey = true,
            elseRoad: () => isPrimaryKey = false,
          );

          bool? isUnique;
          manage.pipelineDivision(
            expected: ["unique"],
            ifRoad: () => isUnique = true,
          );

          dynamic defaultValue;
          manage.pipelineDivision(
            expected: ["default"],
            ifRoad: () {
              defaultValue = manage.consume();
              ////print("parseCreateTable -> $defaultValue");
            },
          );

          bool? nullable;
          manage.pipelineDivision(
            expected: ["not", "null"],
            ifRoad: () {
              nullable = false;
            },
            elseRoad: () {
              if (manage.current == "not" && manage.currentShift(1) != "null") throw MySQLErrorUnexpectedSysnax("null", manage.currentShift(1));
            },
          );
          manage.pipelineDivision(
            expected: ["null"],
            ifRoad: () => nullable = true
          );

          final column = MyColumnSettings(
            name: columnName, 
            type: columnType, 
            isPrimaryKey: isPrimaryKey, 
            nullable: nullable ?? !isPrimaryKey,
            defaultValue: defaultValue,
            isUnique: isUnique ?? isPrimaryKey,
            autoIncrement: autoIncrement
          );
          ////print(column);
          column.checkPrimaryKey();
          columns.add(column);

          manage.consumeOptional(',');
        }
      );
    }

    manage.consume(')');

    return CreateTableStatementNode(tableName: tableName, columns: columns, foreignKey: foreignKey);
  }
}