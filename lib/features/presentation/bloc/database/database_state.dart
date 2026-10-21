import 'package:bloc/bloc.dart';
import 'package:fake_sql/app/export/flutter.dart';
import 'package:fake_sql/features/data/entity/export_database.dart';

class DatabaseState {
  const DatabaseState({
    this.database = MyDB.empty, 
    this.error, 
    this.sqlFieldHistory = const [], 
    this.resultTable,
    this.changes = 0,
    this.backupListWithFileName = const [],
    this.changesBackup = 0,
  });
  final MyDB database;
  final MyTable? resultTable;
  final List<({String query, DateTime time})> sqlFieldHistory;
  final int changes;
  final String? error;
  final List<String> backupListWithFileName;
  final int changesBackup;

  DatabaseState copyWith({
    MyDB? database,
    String? error,
    MyTable? resultTable,
    int? changes,
    List<({String query, DateTime time})>? sqlFieldHistory,
    List<String>? backupListWithFileName,
    int? changesBackup,
  }) {
    return DatabaseState(
      database: database ?? this.database,
      error: error ?? this.error,
      resultTable: resultTable ?? this.resultTable,
      sqlFieldHistory: sqlFieldHistory ?? this.sqlFieldHistory,
      changes: changes ?? this.changes,
      backupListWithFileName:  backupListWithFileName ?? this.backupListWithFileName,
      changesBackup: changesBackup ?? this.changesBackup
    );
  }
}