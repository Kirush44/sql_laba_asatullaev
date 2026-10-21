import 'files_name.dart';
import 'main.dart';

class MyBackup {
  static const pattern = "*& №";

  static void remove() {
    final sp = readOnlyFilesNames();
    //print("MyBackup => readOnlyFilesNames() -> $sp");
    MyLocalStorage.remove(EnumFileNamesTXT.databaseBackup.name);
    for (final s in sp) {
      MyLocalStorage.remove(s);
    }
  }

  static List<String> readOnlyFilesNames() {
    final files = MyLocalStorage.read(EnumFileNamesTXT.databaseBackup.name);
    //print("MyBackup => readOnlyFilesNames() -> $files ${EnumFileNamesTXT.databaseBackup.name}");
    if (files == null) return [];
    return files.split(pattern);
  }

  static String? readByFileName(String fileName) {
    return MyLocalStorage.read(fileName);
  }

  static List<({String fileName, String file})> read() {
    final sp = readOnlyFilesNames();

    List<({String fileName, String file})> res = [];

    for (final s in sp) {
      final file = readByFileName(s);
      if (file == null) continue;
      res.add((fileName: s, file: file));
    }
    return res;
  }

  static void save(String fileName, String file) {
    String? filesBackup = MyLocalStorage.read(EnumFileNamesTXT.databaseBackup.name);
    final newFiles = filesBackup == null ? fileName : "$filesBackup$pattern$fileName";
    MyLocalStorage.save(EnumFileNamesTXT.databaseBackup.name, newFiles);

    MyLocalStorage.save(fileName, file);
  }
}