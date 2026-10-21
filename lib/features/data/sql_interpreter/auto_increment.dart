import 'package:fake_sql/features/data/entity/data_type.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import 'dart:math';

class MyAutoIncrement {
  const MyAutoIncrement(this.data, this.set);

  final MyCellData? data;
  final Set<MyCellData> set;

  MyCellData invoke() {
    final tag = data?.tag ?? _guessTagFromSet();

    switch (tag) {
      case .BOOLEAN: 
        throw MySQLErrorAutoIncrementDontAvailable(tag);
        
      case .FLOAT: 
        final double maxValue = set.isEmpty 
            ? 0.0 
            : (set as Set<MyCellFloat>).map<double>((e) => e.value ?? -999).reduce(max);
            
        if (data == null) {
          return MyCellData.factory(tag, maxValue + 1.0);
        }
        
        final value = double.parse("${data!.value}");
        return MyCellData.factory(tag, value > maxValue ? value : maxValue + 1.0);
        
        case .INT: 
          if (set.isEmpty) {
            if (data == null) return MyCellData.factory(tag, 1);
            final value = int.parse("${data!.value}");
            return MyCellData.factory(tag, value);
          }

          final int maxValue = set
              .map((e) => e.value).where((v) => v != null).map((v) => int.parse("$v"))
              .fold(-999, (maxVal, val) => val > maxVal ? val : maxVal);

          if (data == null) {
            return MyCellData.factory(tag, maxValue == -999 ? 1 : maxValue + 1);
          }
          
          final value = int.parse("${data!.value}");
          return MyCellData.factory(tag, value > maxValue ? value : maxValue + 1);
        
      case .TEXT: 
        throw MySQLErrorAutoIncrementDontAvailable(tag);
        
      case .TIMESTAMP: 
        throw MySQLErrorAutoIncrementDontAvailable(tag);
    }
  }

  EnumCellData _guessTagFromSet() {
    if (set.isNotEmpty) {
      return set.first.tag;
    }
    return .INT;
  }
}