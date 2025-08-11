extension NullString on String {
  String? get orNull => isEmpty ? null : this;
  String? orNullOnDefault(String defaultValue) {
    return (this == defaultValue) ? null : this;
  }
}

extension NullBool on bool {
  bool? get orNullOnFalse => this ? this : null;
  bool? get orNullOnTrue => this ? null : this;
}

extension NullList<T> on List<T> {
  List<T>? get orNull => isEmpty ? null : this;
}

extension ToStringOrNull on Object? {
  String? toStringOrNull() {
    if (this == null) return null;
    return toString();
  }
}

extension RemoveMapNullValue<K, V> on Map<K, V> {
  void removeNullValues() => removeWhere((_, v) => v == null);
  Map<K, V>? get orNull => isEmpty ? null : this;
}

T tryWithFallback<T extends Object>(
  dynamic Function() evaluation, {
  required T fallback,
}) {
  try {
    return evaluation() as T;
  } catch (e) {
    return fallback;
  }
}

T onNull<T extends Object>(T? value, {required T orElse}) {
  if (value == null) return orElse;
  return value;
}
