import 'package:fake_sql/features/data/entity/export_database.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';

class MyColumnSettings {
  const MyColumnSettings({
    required this.name, 
    required this.type, 
    this.isPrimaryKey = false,
    this.autoIncrement = false,
    this.nullable = true,
    this.defaultValue,
    this.isUnique = false
  });

  void checkPrimaryKey() {
    if (isPrimaryKey && nullable) throw MySQLErrorPrimaryKeyIsNull();
    if (isPrimaryKey && !isUnique) throw MySQLErrorPrimaryKeyIsNotUnique();
  }

  final dynamic defaultValue;
  final String name;
  final EnumCellData type;
  final bool isPrimaryKey;
  final bool autoIncrement;
  final bool nullable;
  final bool isUnique;

  MyColumnSettings copyWith({
    String? name,
    EnumCellData? type,
    bool? isPrimaryKey,
    bool? nullable,
    dynamic defaultValue,
    bool? isUnique,
    bool? autoIncrement,
  }) {
    return MyColumnSettings(
      name: name ?? this.name,
      type: type ?? this.type,
      nullable: nullable ?? this.nullable,
      isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
      defaultValue: defaultValue ?? this.defaultValue,
      isUnique: isUnique ?? this.isUnique,
      autoIncrement: autoIncrement ?? this.autoIncrement
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is MyColumnSettings) {
      return other.name == name && other.type == type;
    }
    return super == other;
  }

  @override
  String toString() => "MyColumnSettings(name: $name, type: ${type.name}, isPrimaryKey: $isPrimaryKey, autoIncrement: $autoIncrement, nullable: $nullable, isUnique: $isUnique, defaultValue: $defaultValue)";
}