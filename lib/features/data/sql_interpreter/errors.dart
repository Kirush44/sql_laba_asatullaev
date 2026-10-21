import 'package:fake_sql/features/data/entity/data_type.dart';

abstract class MySQLError implements Exception {
  const MySQLError(this.value);

  final dynamic value;
  String get description;

  @override
  String toString() {
    final t = DateTime.now();
    return "$description: $value (время ${t.hour}:${t.minute}:${t.second})";
  }
}

class MySQLErrorSyntax extends MySQLError implements Exception {
  const MySQLErrorSyntax(super.value);

  @override
  String get description => "Неизвестный символ";
}

class MySQLErrorUnexpectedSysnax extends MySQLError implements Exception {
  final dynamic expect;
  const MySQLErrorUnexpectedSysnax(this.expect, super.value);

  @override
  String get description => "Ожидалось $expect, но получено";
}

class MySQLErrorNotFound extends MySQLError implements Exception {
  const MySQLErrorNotFound(super.value);

  @override
  String get description => "Имя не найдено";
}

class MySQLErrorDontOverlap extends MySQLError implements Exception {
  const MySQLErrorDontOverlap(super.value);

  @override
  String get description => "Уже существует";
}

class MySQLErrorOutRange extends MySQLError implements Exception {
  final List<dynamic> list;
  const MySQLErrorOutRange(this.list) : super(list.length);

  String listToString() {
    String str = "(";
    for (int i = 0 ; i < list.length ; i++) {
      str += "${list[i]}";
      if (i != list.length - 1) {
        str += ", ";
      } else {
        str += ")";
      }
    }
    return str;
  }

  @override
  String get description => "Неожиданная длина данных ${listToString()}";
}

class MySQLErrorColumnDoesntHasNull extends MySQLError implements Exception {
  const MySQLErrorColumnDoesntHasNull(super.value);

  @override
  String get description => "null не установлен для";
}

class MySQLErrorIsUnique extends MySQLError implements Exception {
  final String repeated;
  final String columnName;
  const MySQLErrorIsUnique(this.repeated, this.columnName) : super(columnName);

  @override
  String get description => "$repeated уже существует в";
}

class MySQLErrorPrimaryKeyIsNotUnique extends MySQLError implements Exception {
  const MySQLErrorPrimaryKeyIsNotUnique() : super("Primary key");

  @override
  String get description => "должен быть уникальным";
}

class MySQLErrorPrimaryKeyIsNull extends MySQLError implements Exception {
  const MySQLErrorPrimaryKeyIsNull() : super("Primary key");

  @override
  String get description => "не может быть null";
}

class MySQLErrorAutoIncrementDontAvailable extends MySQLError implements Exception {
  final EnumCellData type;
  const MySQLErrorAutoIncrementDontAvailable(this.type) : super(type);

  @override
  String get description => "Auto increment не доступен";
}