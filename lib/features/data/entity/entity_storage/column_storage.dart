import 'package:fake_sql/features/data/entity/column.dart';
import 'package:fake_sql/features/data/entity/data_type.dart';

extension ColumnSettingsStorage on MyColumnSettings {
  static const pattern = "%''%";
  static MyColumnSettings readStorage(String value) {
    try {
      final sp = value.split(pattern);
      final type = EnumCellData.getType(sp[1]);
      if (type == null) throw Exception("blya ha");
      //print("ColumnSettingsStorage -> готово");
      return MyColumnSettings(
        name: sp[0], 
        type: type, 
        isPrimaryKey: sp[2] == "1" ? true : false,
        nullable: sp[3] == "0" ? false : true,
        defaultValue: sp[4]
      );
    } catch (e) {
      //print("ColumnSettingsStorage -> $e");
      throw Exception("mama $e");
    }
  }

  String saveStorage() {
    return "$name$pattern${type.name}$pattern${isPrimaryKey ? 1 : 0}$pattern${nullable ? 1 : 0}$pattern$defaultValue";
  }
}