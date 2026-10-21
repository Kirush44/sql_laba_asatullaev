enum EnumCellData {
  INT("Int"),
  FLOAT("Float"),
  BOOLEAN("Boolean"),
  TIMESTAMP("Timestamp"),
  TEXT("Text");

  final String name;
  const EnumCellData(this.name);

  static EnumCellData? getType(String value) {
    for (int i = 0 ; i < values.length; i++) {
      if (values[i].name.toLowerCase() == value.toLowerCase()) return values[i];
    }
    return null;
  }
}

abstract class MyCellData<T> {
  final T? value;
  const MyCellData(this.value);

  EnumCellData get tag;

  static MyCellData factory(EnumCellData type, dynamic value) {
    final newValue = value is String ? value : "$value";
    switch (type) {
      case .BOOLEAN: 
        if (newValue == "1") return MyCellBoolean(true);
        if (newValue == "0") return MyCellBoolean(false);
        return MyCellBoolean(bool.tryParse(newValue, caseSensitive: false));

      case .FLOAT: return MyCellFloat(double.tryParse(newValue));
      case .INT: return MyCellInt(int.tryParse(newValue));
      case .TEXT: 
        if (value == null) return MyCellText("null");
        return MyCellText(value);
      case .TIMESTAMP: return MyCellTimestamp(DateTime.tryParse(newValue));
    }
  }

  @override
  int get hashCode => Object.hash(runtimeType, tag, value);

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is MyCellData &&
    runtimeType == other.runtimeType &&
    tag == other.tag &&
    value == other.value; 

  @override
  String toString() => "Cell($value, ${tag.name})";
}

class MyCellText extends MyCellData<String> {
  const MyCellText(super.value);

  @override
  EnumCellData get tag => .TEXT;
}

class MyCellInt extends MyCellData<int> {
  const MyCellInt(super.value);

  @override
  EnumCellData get tag => .INT;
}

class MyCellFloat extends MyCellData<double> {
  const MyCellFloat(super.value);

  @override
  EnumCellData get tag => .FLOAT;
}

class MyCellBoolean extends MyCellData<bool> {
  const MyCellBoolean(super.value);

  @override
  EnumCellData get tag => .BOOLEAN;
}

class MyCellTimestamp extends MyCellData<DateTime> {
  const MyCellTimestamp(super.value);

  @override
  EnumCellData get tag => .TIMESTAMP;
}