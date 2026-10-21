import 'package:fake_sql/app/export/flutter.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';

extension DataCellStorage on MyCellData {
  static const pattern = "@**@";
  static MyCellData readStorage(String value) {
    try {
      final sp = value.split(pattern);
      final type = EnumCellData.getType(sp[1]);
      if (type == null) throw Exception("blya");
      //print("ColumnSettingsStorage -> готово");
      return MyCellData.factory(type, sp[0]);
    } catch (e) {
      //print("DataCellStorage -> $e");
      throw Exception(e);
    }
  }

  String saveStorage() {
    return "$value$pattern${tag.name}";
  }
}