import 'package:fake_sql/features/data/entity/export_database.dart';

import 'table_entity.dart';

class MyDB {
  final List<MyTable> tables;
  final List<MyTableConnect> connects;
  const MyDB(this.tables, {this.connects = const []});

  static const empty = MyDB([], );
  /*
  const Map<String, List<Map<String, dynamic>>> _tables = {
    'users': const [
      {'id': 1, 'name': 'Alice', 'age': 25, 'role': 'admin'},
      {'id': 2, 'name': 'Bob', 'age': 30, 'role': 'user'},
      {'id': 3, 'name': 'Charlie', 'age': 22, 'role': 'user'},
      {'id': 4, 'name': 'Diana', 'age': 35, 'role': 'admin'},
    ],
  };
  */

  ({bool contain, int? index}) contain(String nameTable) {
    for (int i = 0 ; i < tables.length ; i++) {
      if (tables[i].nameTable.toLowerCase() == nameTable.toLowerCase()) {
        return (contain: true, index: i);
      }
    }
    return (contain: false, index: null);
  }

  Map<String, MyTable> get mapTables {
    Map<String, MyTable> res = {};
    for (int i = 0; i < tables.length ; i++) {
      res[tables[i].nameTable.toLowerCase()] = tables[i];
    }
    return res;
  }
  @override
  bool operator ==(Object other) {
    if (other is MyDB) {
      return other.tables.length == this.tables.length 
      || other.tables == this.tables;
    }
    return false;
  }

  MyDB copyWith({
    List<MyTable>? tables,
    List<MyTableConnect>? connects,
  }) {
    return MyDB(
      tables ?? this.tables,
      connects: connects ?? this.connects,
    );
  }

  MyTable? getTable(String name) => tables.firstWhere((e) => e.nameTable == name);

  @override
  String toString() => "MyDB(tables: $tables)";
}