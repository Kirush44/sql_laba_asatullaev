import 'package:fake_sql/app/export/flutter.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/entity/database_entity.dart';
import 'package:fake_sql/features/data/entity/entity_storage/table_storage.dart';
import 'package:fake_sql/features/data/entity/export_database.dart';
import 'connects_storage.dart';

extension DBStorage on MyDB {
  static const pattern = "*МАьА*";
  static const patternTable = "ХЕмаЕХ";
  static const patternConnects = "?чТо?";

  static MyDB readStorage(String value) {
    final sp = value.split(pattern);

    final spTables = sp[0].split(patternTable);
    List<MyTable> ts = [];
    if (spTables.isNotEmpty && spTables[0] != '') {
      for (int i = 0 ; i < spTables.length ; i++) {
        ts.add(MyTableStorage.readStorage(spTables[i]));
      }
    }
    //print("DBStorage -> ts $ts");

    final spConnects = sp[1].split(patternConnects);
    List<MyTableConnect> cns = [];
    //print("DBStorage -> sp1 ${spConnects[0] == ''}");
    if (spConnects.isNotEmpty && spConnects[0] != '') {
      for (int i = 0 ; i < spConnects.length ; i++) {
        //print("DBStorage -> ${spConnects[i]}");
        cns.add(TableConnectStorage.readStorage(spConnects[i]));
      }
    }

    //print("DBStorage -> ураа");
    return MyDB(ts, connects: cns);
  }

  String saveStorage() {

    String db = "";
    for (int i = 0 ; i < tables.length ; i++) {
      db += tables[i].saveStorage();
      if (i != tables.length - 1) db += patternTable;
    }

    String cons = "";
    for (int i = 0 ; i < connects.length ; i++) {
      cons += connects[i].saveStorage();
      if (i != connects.length - 1) db += patternConnects;
    }

    return "$db$pattern$cons";
  }
}