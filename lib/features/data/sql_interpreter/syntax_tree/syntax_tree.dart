import '../../entity/export_database.dart';

abstract class ASTNode {
  @override
  String toString();

  MyDB invoke(MyDB database);
}

abstract class ASTSupportNode {
  @override
  String toString();
}