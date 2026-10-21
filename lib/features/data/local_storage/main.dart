import 'package:web/web.dart' as web;

class MyLocalStorage {

  static void save(String fileName, String content) {
    try {
      web.window.localStorage.setItem(fileName, content);
      //print("MyLocalStorage -> save -> $fileName ${content.length}");
    } catch (e) {
      //print("беда");
    }
  }

  static String? read(String fileName) {
    try {
      final file = web.window.localStorage.getItem(fileName);
      //print("MyLocalStorage -> read -> $file");
      return file;
    } catch (e) {
      //print("беда");
      throw Exception("беда емае боже");
    }
  }

  static void remove(String fileName) => web.window.localStorage.removeItem(fileName);
}