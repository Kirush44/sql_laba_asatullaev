abstract class MyLocalStorageError implements Exception {
  const MyLocalStorageError(this.value);

  final dynamic value;
  String get description;

  @override
  String toString() {
    final t = DateTime.now();
    return "$description: $value (время ${t.hour}:${t.minute}:${t.second})";
  }
}