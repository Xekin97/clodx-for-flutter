import 'main.dart';

typedef ClodVisitorGenerator = ClodVisitor<T> Function<T>(
    Clod<ClodValueType<T>> clod);
typedef ClodControllerGenerator = ClodController<T> Function<T>(
    Clod<ClodValueType<T>> clod);

typedef Picker<T> = T Function(ClodVisitorGenerator visit);
typedef Maker<T> = Function(
    T value, ClodVisitorGenerator visit, ClodControllerGenerator control);

sealed class ClodValueType<T> {}

class ClodNormalValue<T> extends ClodValueType<T> {
  T value;
  bool Function(T prev, T next)? equal;
  ClodNormalValue(this.value, {this.equal});
}

class ClodPickValue<T> extends ClodValueType<T> {
  Picker<T> value; // (methods) { return methods.get(clod); }
  bool Function(T prev, T next)? equal;
  ClodPickValue(this.value, {this.equal});
}

class ClodMakeValue<T> extends ClodValueType<T> {
  Maker<T> value; // (value, methods) { return methods.get(clod) + value; }
  ClodMakeValue(this.value);
}
