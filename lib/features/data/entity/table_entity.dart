import 'data_type.dart';
import 'table_connect.dart';
import 'column.dart';

class MyTable {
  final String nameTable;

  /// лист строк -> лист данных
  final List<List<MyCellData>> dataset;
  final List<MyColumnSettings> names;

  const MyTable({required this.dataset, required this.names, required this.nameTable});

  bool get checkLen {
    for (int i = 0 ; i < dataset.length; i++) {
      if (dataset[i].length != names.length) return false;
    }
    return true;
  }

  List<({String name, String type})> get namesWithTypeName {
    List<({String name, String type})> res = [];
    for (int i = 0 ; i < names.length; i++) {
      res.add((name: names[i].name, type: names[i].type.name));
    }
    return res;
  }


  List<Map<String, MyCellData>> get tableSet {
    List<Map<String, MyCellData>> res = [];
    for (int i = 0 ; i < dataset.length; i++) {
      if (dataset[i].length != names.length) throw Exception("dataset[i].length != names.length");
      Map<String, MyCellData> _set = {};
      for (int j = 0 ; j < dataset[i].length; j++) {
        _set[names[j].name] = dataset[i][j];
      }
      res.add(_set);
    }
    return res;
  }

  MyTable copyWith({
    String? nameTable,
    List<List<MyCellData>>? dataset,
    List<MyColumnSettings>? names,
  }) {
    return MyTable(
      nameTable: nameTable ?? this.nameTable,
      dataset: dataset ?? this.dataset,
      names: names ?? this.names,
    );
  }

  @override
  String toString() => "MyTable(nameTable: $nameTable, dataset: $dataset)";
}
