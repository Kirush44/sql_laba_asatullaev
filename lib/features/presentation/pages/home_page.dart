import 'package:fake_sql/features/data/entity/export_database.dart';
import 'package:fake_sql/features/data/local_storage/files_name.dart';
import 'package:fake_sql/features/data/local_storage/main.dart';
import 'package:material_ui/material_ui.dart';
import '../../../features/presentation/widgets/export_widgets.dart';
import '../../../app/export/bloc.dart';
import '../../../app/export/flutter.dart';
import '../../../app/export/packages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controllerSQL = CodeEditorController();
  late final ValueNotifier<int?> tableViewIndex;
  late final ConfettiController controllerConfetti;

  WeButton mybtn({
    required Widget child, 
    void Function()? callback,
    Color? color,
    Color? colorBorder,
    }) {
    return WeButton(
      color: color ?? Theme.of(context).colorScheme.onSurface,
      borderRadius: .circular(12),
      padding: .all(8),
      border: .all(width: 1, color: colorBorder ?? Theme.of(context).colorScheme.secondary) ,
      callback: callback,
      child: child,
    );
  }

  Future<void> get openGitHup async => launchUrl(Uri.parse('https://github.com/Kirush44/sql_laba_asatullaev'), mode: .externalApplication);

  @override
  void initState() {
    super.initState();
    context.read<DatabaseBloc>()
      ..add(DatabaseEventGetLocalStorage())
      ..add(DatabaseEventGetBackupFileName());
    tableViewIndex = ValueNotifier<int?>(null);
    controllerConfetti = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    controllerSQL.dispose();
    tableViewIndex.dispose();
    controllerConfetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          crossAxisAlignment: .end,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(widget.title, style: .new(color: Theme.of(context).colorScheme.primary),),
            Row(
              crossAxisAlignment: .end,
              spacing: 12,
              children: [
                mybtn(
                  child: Text("Удалить все бэкапы", style: .new(color: Theme.of(context).colorScheme.primary, fontSize: 14),),
                  callback: () => context.read<DatabaseBloc>().add(DatabaseEventRemoveBackup()),
                ),
                BlocBuilder<DatabaseBloc, DatabaseState>(
                  buildWhen: (p, c) => p.changesBackup != c.changesBackup,
                  builder: (context, state) {
                    return WeDropMenu(
                      maxHeight: 250,
                      width: 340,
                      colorText: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      border: .all(width: 1, color: Theme.of(context).colorScheme.secondary),
                      items: List.generate(
                        state.backupListWithFileName.length,
                        (i) {
                          return WeDropMenuItem(
                            text: state.backupListWithFileName[state.backupListWithFileName.length - i - 1],
                            onTap: () => context.read<DatabaseBloc>().add(DatabaseEventSetDatabaseFromBackup(state.backupListWithFileName[i])),
                          );
                        }
                      ),
                      child: AbsorbPointer(
                        child: mybtn(
                          child: Text("Бэкапы", style: .new(color: Theme.of(context).colorScheme.primary, fontSize: 14),),
                        ),
                      )
                    );
                  }
                ),
                mybtn(
                  child: Text("Гитхаб", style: .new(color: Theme.of(context).colorScheme.primary, fontSize: 14),),
                  callback: () async => await openGitHup
                ),
                mybtn(
                  color: Colors.pinkAccent,
                  colorBorder: Colors.transparent,
                  child: Text("README", style: .new(color: Theme.of(context).colorScheme.primary, fontSize: 14),),
                ),
              ],
            )
          ],
        )
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: .all(12),
            child: WeMultiWindowLayout(
              borderRadius: .circular(24),
              border: Border.all(
                width: 1, 
                color: Theme.of(context).colorScheme.secondary.withAlpha(160), 
                strokeAlign: 1,
              ),
              gap: 12,
              minHeight: 400,
              minWidth: 800,
              colorDivider: Theme.of(context).colorScheme.tertiary,
              layout: [
                [
                  WindowConfig(
                    child: WeScreenCard(
                      padding: .all(12),
                      color: Colors.transparent,
                      bottomButtons: [
                        mybtn(
                          color: Colors.pinkAccent,
                          colorBorder: Colors.transparent,
                          child: Text("Сохранить на будущее", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            context.read<DatabaseBloc>().add(DatabaseEventSetBackup());
                          },
                        ),
                        mybtn(
                          child: Text("Удалить все", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            //print("ale");
                            context.read<DatabaseBloc>().add(DatabaseEventClear());
                          },
                        ),
                        mybtn(
                          child: Text("Тестовая база", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            context.read<DatabaseBloc>().add(DatabaseEventNewTables(
                              [
                                .new(
                                  nameTable: "dataset",
                                  dataset: List.generate(
                                    30,
                                    (i) => [
                                      MyCellInt(i + 1), 
                                      MyCellText(i % 6 == 0 ? "chapman" : "test_${i + 1}"), 
                                      MyCellBoolean(i % 2 == 0)
                                    ]
                                  ), 
                                  names: [
                                    MyColumnSettings(name: "id", type: .INT, isPrimaryKey: true, isUnique: true, autoIncrement: true),
                                    MyColumnSettings(name: "name", type: .TEXT, isPrimaryKey: false),
                                    MyColumnSettings(name: "task", type: .BOOLEAN, defaultValue: true, isPrimaryKey: false),
                                  ], 
                                  
                                ),
                                .new(
                                  nameTable: "models",
                                  dataset: List.generate(
                                    20,(i) => [
                                      MyCellInt(i + 1), 
                                      MyCellText("vovka"), 
                                      MyCellInt(12 + i)
                                    ]
                                  ), 
                                  names: [
                                    MyColumnSettings(name: "id", type: .INT, isPrimaryKey: true),
                                    MyColumnSettings(name: "name", type: .TEXT, isPrimaryKey: false),
                                    MyColumnSettings(name: "version", type: .INT, isPrimaryKey: false),
                                  ], 
                                  
                                ),
                                .new(
                                  nameTable: "experiments",
                                  dataset: List.generate(
                                    10, (i) => 
                                    [
                                      MyCellInt(i + 1), 
                                      MyCellInt(i % 7 < 4 ? i + 1 : (i % 7) + 1), 
                                      MyCellInt(i + 1 % 6 > 4 ? i : i % 5),
                                      MyCellFloat(10 * (10 - i - 1) ~/ 1 / 100),
                                      MyCellText(['completed', 'running', 'inactive'][(2*i + i*i + 1) % 3]),
                                    ]
                                    ), 
                                  names: [
                                    MyColumnSettings(name: "id", type: .INT, isPrimaryKey: true),
                                    MyColumnSettings(name: "dataset_id", type: .INT),
                                    MyColumnSettings(name: "model_id", type: .TEXT),
                                    MyColumnSettings(name: "accuracy", type: .FLOAT, defaultValue: 0),
                                    MyColumnSettings(name: "status", type: .TEXT, defaultValue: 'inactive'),
                                  ], 
                                  
                                ),
                              ]
                            ));
                          },
                        ),
                      ],
                      child: WeDotGridBackground(
                        
                        dotColor: Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        child: BlocBuilder<DatabaseBloc, DatabaseState>(
                          buildWhen: (p, c) => p.changes != c.changes,
                          builder: (context, state) {
                            return WeDatabaseHolder(
                              colorMainText: Theme.of(context).colorScheme.primary,
                              colorText: Theme.of(context).colorScheme.secondary,
                              color: Theme.of(context).colorScheme.surface,
                              colorHeader: Theme.of(context).colorScheme.onSurface,
                              border: .all(width: 1, color: Theme.of(context).colorScheme.tertiary),
                              onTap: (t, i) => tableViewIndex.value = i,
                              database: MyDB(state.database.tables),
                            );
                          }
                        )
                      ),
                    )
                  ),
                ],
                [
                  WindowConfig(
                    child: WeScreenCard(
                      padding: .all(12),
                      color: Theme.of(context).colorScheme.onSurface,
                      topButtons: [
                        mybtn(
                          child: Text("CREATE TABLE", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = "CREATE TABLE Dataset_prikol (\n"
                                "  id INT AUTO_INCREMENT PRIMARY KEY,\n"
                                "  uni int UNIQUE,\n"
                                "  noyy_null TEXT NOT NULL,\n"
                                "  default_true BOOLEAN DEFAULT TRUE,\n"
                                "  default_not_null FLOAT DEFAULT TRUE NOT NULL,\n"
                                "  unique_default_not_null TEXT UNIQUE DEFAULT TRUE NOT NULL,\n"
                                "  FOREIGN KEY uni REFERENCES Dataset(id)\n"
                              ")";
                          },
                        ),
                        mybtn(
                          child: Text("INSERT INTO", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = 'INSERT INTO Models VALUES (11, "vai_mama", 52), (14, "hi", 13)';
                          },
                        ),
                        mybtn(
                          child: Text("UPDATE", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = 'UPDATE Dataset SET name = "new_name" WHERE id > 2 and ( id < 10 or id = 12 )';
                          },
                        ),
                        mybtn(
                          child: Text("SELECT", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = "SELECT * FROM Dataset WHERE task = true and ( id < 10  or name = 'chapman')";
                          },
                        ),
                        mybtn(
                          child: Text("DELETE", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = "DELETE FROM Models WHERE id > 2";
                          },
                        ),
                        mybtn(
                          child: Text("DROP TABLE", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = "DROP TABLE IF EXISTS Models";
                          },
                        ),
                      ],
                      bottomButtons: [
                        mybtn(
                          color: Colors.pinkAccent,
                          colorBorder: Colors.transparent,
                          child: Text("Запустить", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            
                            if (context.read<DatabaseBloc>().state.changes % 7 == 0) controllerConfetti.play();
                            context.read<DatabaseBloc>().add(DatabaseEventQuery(controllerSQL.text));
                          },
                        ),
                        mybtn(
                          child: Text("Очистить", style: .new(color: Theme.of(context).colorScheme.primary)),
                          callback: () {
                            controllerSQL.text = "\n\n  ";
                          },
                        ),
                        BlocBuilder<DatabaseBloc, DatabaseState>(
                          buildWhen: (p, c) => p.changes != c.changes,
                          builder: (context, state) {
                            if (state.error == null || state.error!.isEmpty) return const SizedBox.shrink();
                            return mybtn(
                              color: Colors.pinkAccent.withAlpha(32),
                              colorBorder: Colors.pinkAccent,
                              child: Text(
                                "ОШИБКА! ${state.error!.toLowerCase()}", 
                                style: .new(color: Theme.of(context).colorScheme.primary)
                              ),
                            );
                          }
                        )

                      ],
                      
                      childBetweenButtons: LayoutBuilder(
                            builder: (context, con) {
                              return SizedBox(
                                height: 250,
                                width: con.maxWidth,
                                child: WeSqlCodeEditor(
                                  textColor: Colors.white,
                                  lineNumberColor: Colors.grey,
                                  keywords: {
                                    "WHERE", "SELECT", "DROP", "TABLE", "IF", "EXISTS", 
                                    "FROM", "FOREIGN", "KEY", "REFERENCES", "CREATE", "DELETE",
                                    "INSERT", "INTO", "VALUES", "UPDATE", "SET",
                                    "INT", "TEXT", "BOOLEAN", "PRIMARY", "FLOAT",
                                    "DEFAULT", "TRUE", "NOT", "NULL", "UNIQUE", "AUTO_INCREMENT",
                                    "AND", "OR"
                                  },
                                  controller: controllerSQL,
                                ),
                              );
                            },
                             
                          ),
                    )
                  ),
                  WindowConfig(
                    child: ValueListenableBuilder(
                      valueListenable: tableViewIndex, 
                      builder: (context, value, child) {
                        
                        return BlocBuilder<DatabaseBloc, DatabaseState>(
                          buildWhen: (p, c) => p.changes != c.changes,
                          builder: (context, state) {

                            return WeScreenCard(
                              color: Theme.of(context).colorScheme.onSurface,
                              padding: .all(12),
                              topButtons: [
                                for (int? i in [null, ...List.generate(state.database.tables.length, (i) => i)]) mybtn(
                                  color: i == value ? Colors.pinkAccent : null,
                                  colorBorder: i == value ? Colors.transparent : null,
                                  child: Text(
                                    i == null 
                                    ? "Результат" 
                                    : state.database.tables[i].nameTable, 
                                    
                                    style: .new(color: Theme.of(context).colorScheme.primary),
                                  ),
                                  callback: () => tableViewIndex.value = i,
                                )
                              ],
                              childBetweenButtons: WeTableView(
                                colorRowId: Theme.of(context).colorScheme.tertiary,
                                colorRowSecondary: Theme.of(context).colorScheme.tertiary,
                                colorRowPrimary: Theme.of(context).colorScheme.surface,
                                textStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                                table: 
                                  value == null || value > state.database.tables.length - 1
                                  ? state.resultTable
                                  : state.database.tables[value],
                              )
                            );
                          }
                        );
                      }
                    )
                  ),
                ],
              ]
            ),
          ),
          WeConfetti(
            controllerConfetti: controllerConfetti,
          )  
        ],
      )
    );
  }
}
