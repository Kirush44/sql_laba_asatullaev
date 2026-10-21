import 'package:fake_sql/app/export/flutter.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/entity/entity_storage/column_storage.dart';
import 'package:fake_sql/features/data/entity/export_database.dart';

extension TableConnectStorage on MyTableConnect {
  static const pattern = ":Ё ~";

  static MyTableConnect readStorage(String value) {
    try {
      final sp = value.split(pattern);
      //print("TableConnectStorage -> $sp $value $pattern");

      final fromTable = sp[0];

      final from = ColumnSettingsStorage.readStorage(sp[1]);
      
      final toTable = sp[2];

      final to = ColumnSettingsStorage.readStorage(sp[3]);

      //print("TableConnectStorage -> все норм");
      return MyTableConnect(fromTable, from, toTableName: toTable, columnTo: to);
    } catch (e) {
      //print("TableConnectStorage -> $e");
      throw Exception("TableConnectStorage -> $e");
    }
  }

  String saveStorage() {

    final from = columnFrom.saveStorage();
    final fromTable = fromTableName;
    final to = columnTo.saveStorage();
    final toTable = toTableName;

    return "$fromTable$pattern$from$pattern$toTable$pattern$to";
  }
}