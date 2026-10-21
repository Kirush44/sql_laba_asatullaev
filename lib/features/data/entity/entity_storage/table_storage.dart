import 'package:fake_sql/features/data/entity/column.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/entity/entity_storage/column_storage.dart';
import 'package:fake_sql/features/data/entity/entity_storage/connects_storage.dart';
import 'package:fake_sql/features/data/entity/entity_storage/data_storage.dart';
import 'package:fake_sql/features/data/entity/export_database.dart';

extension MyTableStorage on MyTable {
  static const pattern = "^ ?%";
  static const patternColumn = ":^ %";
  static const patternRow = ":@ @";
  static const patternColumnSettings = "!~&;";
  static const patternColumnConnect = "~@~~";

  static MyTable readStorage(String value) {
    final sp = value.split(pattern);
    final nameTable = sp[0];

    final rowNames = sp[2].split(patternColumnSettings);
    final List<MyColumnSettings> _names = List.generate(rowNames.length, (i) => ColumnSettingsStorage.readStorage(rowNames[i]));

    final rowsDataset = sp[1].split(patternColumn);
    final List<List<MyCellData>> _dataset 
    = rowsDataset.isEmpty || rowsDataset[0] == '' 
    ? []
    : List.generate(
      rowsDataset.length, 
      (i) {
        
        final dataInRow = rowsDataset[i].split(patternRow);
        return List.generate(
          dataInRow.length, 
          (j) => DataCellStorage.readStorage(dataInRow[j])
        );
      }
    );

    return MyTable(nameTable: nameTable, names: _names, dataset: _dataset);
  }

  String saveStorage() {

    final String name = nameTable;

    String columnSettings = "";

    for (int i = 0 ; i < names.length ; i++) {
      columnSettings += names[i].saveStorage();
      if (i != names.length - 1) columnSettings += patternColumnSettings;
    }

    String data = "";
    for (int i = 0 ; i < dataset.length ; i++) {
      for (int j = 0 ; j < dataset[i].length ; j++) {
        data += dataset[i][j].saveStorage();
        if (j != dataset[i].length - 1) data += patternRow;
      }
      if (i != dataset.length - 1) data += patternColumn;
    }



    return "$name$pattern$data$pattern$columnSettings";
  }
}