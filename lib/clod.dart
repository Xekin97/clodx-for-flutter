import './main.dart';

const clodKeyPrefix = '#CLOD_';

final idGener = createUnionIdGener();

String createClodKey() {
  return "$clodKeyPrefix${idGener()}";
}

bool commonEqual(dynamic a, dynamic b) {
  if (a == null && b == null) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  return a == b;
}

class Clod<T> {
  late String key;
  late T meta;

  Set<void Function()> depUpdateSet = {};
  Set<Clod> depClodSet = {};
  List<Function> onUpdateCallbacks = [];

  Clod(T state) {
    key = createClodKey();
    meta = state;
  }

  callbackUpdates() {
    for (var callback in onUpdateCallbacks) {
      callback();
    }
  }

  onUpdate(void Function() callback) {
    onUpdateCallbacks.add(callback);
  }

  update() {
    for (var callback in depUpdateSet) {
      callback();
    }

    for (var clod in depClodSet) {
      if (clod is PickClod) {
        clod.pick();
      } else {
        clod.update();
      }
    }

    callbackUpdates();
  }

  depClod(Clod clod) {
    if (clod == this) {
      return;
    }
    if (Clod.isClodCircularDeps(this, clod)) {
      throw 'These clods create circular dependencies.';
    }

    clod.depClodSet.add(this);
  }

  unDepClod(Clod clod) {
    clod.depClodSet.remove(this);
  }

  depUpdate(void Function() callback) {
    depUpdateSet.add(callback);
  }

  unDepUpdate(void Function() callback) {
    depUpdateSet.remove(callback);
  }

  dispose() {
    depClodSet.clear();
    depUpdateSet.clear();
    onUpdateCallbacks.clear();
  }

  static isClodCircularDeps(Clod a, Clod b) {
    Set<Clod> deps = Clod.getClodDependencies(b);
    return deps.contains(a);
  }

  static getClodDependencies(Clod clod) {
    Set<Clod> deps = {};

    void check(Clod target) {
      for (var depClod in target.depClodSet) {
        if (deps.contains(clod)) {
          return;
        }
        deps.add(clod);
        check(depClod);
      }
    }

    check(clod);
    return deps;
  }

  static clone() {}
}

class NormalClod<T> extends Clod<ClodNormalValue<T>> {
  late T current;

  pick() {
    return current;
  }

  make(T value) {
    updateValue(value);
  }

  updateValue(T value) {
    final equal = meta.equal ?? commonEqual;
    if (!equal(current, value)) {
      current = value;
      update();
    }
  }

  NormalClod(ClodNormalValue<T> value) : super(value) {
    current = value.value;
  }

  static clone() {}
}

class PickClod<T> extends Clod<ClodPickValue<T>> {
  T? current;

  V getter<V>(NormalClod<V> clod) {
    depClod(clod);
    return clod.current;
  }

  V picker<V>(PickClod<V> clod) {
    depClod(clod);
    return clod.pick();
  }

  pick() {
    final valueAfter = meta.value(PickMethods(getter, picker));
    updateValue(valueAfter);
    return valueAfter;
  }

  updateValue(T value) {
    final equal = meta.equal ?? commonEqual;
    if (current == null || !equal(current as T, value)) {
      current = value;
      update();
    }
  }

  PickClod(super.value);
}

class MakeClod<T> extends Clod<ClodMakeValue<T>> {
  V getter<V>(NormalClod<V> clod) {
    depClod(clod);
    return clod.current;
  }

  V picker<V>(PickClod<V> clod) {
    depClod(clod);
    return clod.pick();
  }

  setter<V>(NormalClod<V> clod, V value) {
    clod.make(value);
  }

  maker<V>(MakeClod<V> clod, V value) {
    clod.make(value);
  }

  make(T value) {
    meta.value(value, MakeMethods(getter, picker, setter, maker));
  }

  MakeClod(super.value);
}
