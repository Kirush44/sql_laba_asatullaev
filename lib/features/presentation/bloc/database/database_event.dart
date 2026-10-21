import 'package:fake_sql/features/data/entity/table_entity.dart';

abstract class DatabaseEvent {
  const DatabaseEvent();
}

class DatabaseEventGetLocalStorage extends DatabaseEvent {}

class DatabaseEventSetBackup extends DatabaseEvent {}

class DatabaseEventRemoveBackup extends DatabaseEvent {}

class DatabaseEventGetBackupFileName extends DatabaseEvent {}

class DatabaseEventSetDatabaseFromBackup extends DatabaseEvent {
  const DatabaseEventSetDatabaseFromBackup(this.fileName);
  final String fileName;
}

class DatabaseEventClear extends DatabaseEvent {}

class DatabaseEventQuery extends DatabaseEvent {
  const DatabaseEventQuery(this.query);

  final String query;
}

class DatabaseEventNewTables extends DatabaseEvent {
  const DatabaseEventNewTables(this.tables);

  final List<MyTable> tables;
}