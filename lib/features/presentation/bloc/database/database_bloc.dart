import 'package:fake_sql/features/data/entity/entity_storage/database_storage.dart';
import 'package:fake_sql/features/data/local_storage/backup_list.dart';
import 'package:fake_sql/features/data/local_storage/files_name.dart';
import 'package:fake_sql/features/data/local_storage/main.dart';
import 'package:fake_sql/features/data/sql_interpreter/errors.dart';
import 'package:fake_sql/features/data/sql_interpreter/syntax_tree/export_nodes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/sql_interpreter/main.dart';
import '../../../data/entity/export_database.dart';
import 'database_event.dart';
import 'database_state.dart';

export 'database_event.dart';
export 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  DatabaseBloc() : super(DatabaseState()) {
    on<DatabaseEventQuery>(_query);
    on<DatabaseEventNewTables>(_newTables);
    on<DatabaseEventClear>(_clear);
    on<DatabaseEventSetBackup>(_setBackup);
    on<DatabaseEventSetDatabaseFromBackup>(_setDBFromBackup);
    on<DatabaseEventGetBackupFileName>(_getBackupFileName);
    on<DatabaseEventGetLocalStorage>(_get);
    on<DatabaseEventRemoveBackup>(_removeBackup);
  }

  void printBloc(String funcName, dynamic value, [String valueName = ""]) => null; // //print("DatabaseBloc -> $funcName -> ${valueName.isEmpty ? "" : "$valueName: "} $value");

  Future<void> _query(DatabaseEventQuery event, Emitter emit) async {
    printBloc("_query", event.query);
    printBloc("_query", state.database,"database");
    

    try {
      emit(state.copyWith(error: ""));
      List<({String query, DateTime time})> history 
        = List.from(state.sqlFieldHistory)..add((query: event.query, time: DateTime.now()));
        
      emit(state.copyWith(sqlFieldHistory: history));

      final parsed = await SqlParser.parse(event.query);

      final db = state.database;
      
      /// Отдельный случай для SELETC
      if (parsed is SelectStatementNode) {
        emit(state.copyWith(resultTable: parsed.invoke(db).tables[0]));
      } else {
        final finalDB = parsed.invoke(db);
        emit(state.copyWith(database: finalDB));

        _set();
      }
      
      emit(state.copyWith(changes: state.changes + 1));
      printBloc("_query", parsed);

    } on MySQLError catch (e) {
      emit(state.copyWith(error: "$e", changes: state.changes + 1));

    } catch (e) {
      printBloc("_query", e, "error");
      emit(state.copyWith(error: "$e", changes: state.changes + 1));
      
    }
  }


  void _newTables(DatabaseEventNewTables event, Emitter emit) {
    

    final List<MyTable> tables = [...state.database.tables, ...event.tables];
    final db = state.database.copyWith(tables: tables);
    emit(state.copyWith(database: db, changes: state.changes + 1));
    _set();

  }

  void _clear(DatabaseEventClear event, Emitter emit) {
    ////print("aleee");
    final db = state.database.copyWith(tables: []);
    ////print("check $db");
    emit(state.copyWith(database: db, changes: state.changes + 1));
    _set();
  }



  void _get(DatabaseEventGetLocalStorage event, Emitter emit) {
    try {
      final databaseRaw = MyLocalStorage.read(EnumFileNamesTXT.database.name);
      if (databaseRaw == null) {
        printBloc("_get", "пустая");
         return;
      }
      final db = DBStorage.readStorage(databaseRaw);
      printBloc("_get", "$db", "наконец");
      emit(state.copyWith(database: db, changes: state.changes + 1));
    } catch (e) {
      printBloc("_get", e, "error");
    }
  }

  void _set() {
    final txt = state.database.saveStorage();
    MyLocalStorage.save(EnumFileNamesTXT.database.name, txt);
  }

  Future<void> _setBackup(DatabaseEventSetBackup event, Emitter emit) async {
    final txt = state.database.saveStorage();
    final fileName = EnumFileNamesTXT.database.nameWithSuffix(DateTime.now().toIso8601String());
    emit(state.copyWith(backupListWithFileName: state.backupListWithFileName..add(fileName), changesBackup: state.changesBackup + 1));
    await Future(() => MyBackup.save(fileName, txt));
    ////print("$runtimeType -> ${state.backupListWithFileName}");
  }

  Future<void> _setDBFromBackup(DatabaseEventSetDatabaseFromBackup event, Emitter emit) async {
    final databaseRaw = MyBackup.readByFileName(event.fileName);
    if (databaseRaw == null) return;
    emit(state.copyWith(database: DBStorage.readStorage(databaseRaw), changes: state.changes + 1));
    _set();
  }

  void _getBackupFileName(DatabaseEventGetBackupFileName event, Emitter emit) {
    final names = MyBackup.readOnlyFilesNames();
    ////print("_getBackupFileName -> $names");
    emit(state.copyWith(backupListWithFileName: names, changesBackup: state.changesBackup + 1));
  }

  void _removeBackup(DatabaseEventRemoveBackup event, Emitter emit) {
    MyBackup.remove();
    emit(state.copyWith(backupListWithFileName: [], changesBackup: state.changesBackup + 1));
  }
}