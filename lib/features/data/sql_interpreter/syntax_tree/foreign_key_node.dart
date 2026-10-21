import 'syntax_tree.dart';


class ForeignKeyStatementNode extends ASTSupportNode {
  final String keyColumnName;
  final String referencesColumnName;
  final String referencesNameTable;

  ForeignKeyStatementNode({
    required this.keyColumnName,
    required this.referencesNameTable,
    required this.referencesColumnName,
  });

  @override
  String toString() => 
      'ForeignKeyStatementNode(key: $keyColumnName, referencesNameTable: $referencesNameTable, referencesColumn: $referencesColumnName)';
}