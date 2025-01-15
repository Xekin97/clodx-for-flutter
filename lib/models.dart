import './main.dart';

typedef NormalClodPicker = T Function<T>(NormalClod<T> clod);

typedef PickClodPicker = T Function<T>(PickClod<T> clod);

typedef NormalClodSetter = void Function<V>(NormalClod<V> clod, V value);

typedef MakeClodSetter = void Function<V>(MakeClod<V> clod, V value);

class PickMethods {
  NormalClodPicker get;
  PickClodPicker pick;
  PickMethods(this.get, this.pick);
}

class MakeMethods {
  NormalClodPicker get;
  PickClodPicker pick;
  NormalClodSetter set;
  MakeClodSetter make;
  MakeMethods(this.get, this.pick, this.set, this.make);
}

typedef Picker<T> = T Function(PickMethods methods);
typedef Maker<T> = Function(T value, MakeMethods methods);

class ClodNormalValue<T> {
  T value;
  bool Function(T prev, T next)? equal;
  ClodNormalValue(this.value, {this.equal});
}

class ClodPickValue<T> {
  Picker<T> value; // (methods) { return methods.get(clod); }
  bool Function(T prev, T next)? equal;
  ClodPickValue(this.value, {this.equal});
}

class ClodMakeValue<T> {
  Maker<T> value; // (value, methods) { return methods.get(clod) + value; }
  ClodMakeValue(this.value);
}
