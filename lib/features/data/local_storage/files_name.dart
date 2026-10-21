enum EnumFileNamesTXT {
  database("database"),
  databaseBackup("database_backup_list");

  String get name => "$tag.txt";
  final String tag;
  const EnumFileNamesTXT(this.tag);

  String nameWithSuffix(String suffix) {
    return "${this.tag}_$suffix.txt";
  }
}

