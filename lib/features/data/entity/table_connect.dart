import 'package:fake_sql/features/data/entity/column.dart';
import 'package:fake_sql/features/data/entity/table_entity.dart';

class MyTableConnect {
  final String fromTableName;
  final MyColumnSettings columnFrom;
  final String toTableName;
  final MyColumnSettings columnTo;

  const MyTableConnect(this.fromTableName, this.columnFrom, {required this.toTableName, required this.columnTo});
}