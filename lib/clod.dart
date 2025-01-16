import 'main.dart';

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

class ClodVisitor<T> {
  Clod<ClodValueType<T>> clod;

  T value() {
    if (clod is NormalClod) {
      return (clod as NormalClod).current;
    } else if (clod is PickClod) {
      return (clod as PickClod).pick();
    } else {
      throw UnsupportedError(
          'Unsupport to get value of this clod. ${clod.key}');
    }
  }

  ClodVisitor(this.clod);
}

class ClodController<T> {
  Clod<ClodValueType<T>> clod;
  set(T value) {
    if (clod is NormalClod || clod is MakeClod) {
      (clod as NormalClod).make(value);
    } else {
      throw UnsupportedError(
          'Unsupport to set value of this clod. ${clod.key}');
    }
  }

  ClodController(this.clod);
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

  ClodVisitor<V> visitorGenerate<V>(Clod<ClodValueType<V>> clod) {
    depClod(clod);
    return ClodVisitor(clod);
  }

  pick() {
    final valueAfter = meta.value(visitorGenerate);
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
  ClodVisitor<V> visitorGenerate<V>(Clod<ClodValueType<V>> clod) {
    depClod(clod);
    return ClodVisitor(clod);
  }

  ClodController<V> controllerGenerate<V>(Clod<ClodValueType<V>> clod) {
    return ClodController(clod);
  }

  make(T value) {
    meta.value(value, visitorGenerate, controllerGenerate);
  }

  MakeClod(super.value);
}
