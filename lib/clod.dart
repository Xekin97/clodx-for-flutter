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

class ClodUpdator {
  ClodUpdator._();

  factory ClodUpdator() => updator;

  static final ClodUpdator updator = ClodUpdator._();

  bool updating = false;

  Set<Clod> cache = {};

  // a -> b -> c
  // a -> c

  static update(Clod clod) {
    if (updator.updating) {
      for (var clod in clod.depClodSet) {
        updator.cache.add(clod);
        update(clod);
      }
      return;
    }

    updator.updating = true;

    for (var clod in clod.depClodSet) {
      updator.cache.add(clod);
      update(clod);
    }

    for (var clod in updator.cache) {
      clod.callDepUpdates();

      if (clod is NormalClod) {
        update(clod);
      } else if (clod is PickClod) {
        clod.pick();
      }
    }

    updator.updating = false;
    updator.cache.clear();
  }
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
    ClodUpdator.update(this);
  }

  depClod(Clod clod) {
    if (clod == this) {
      return;
    }

    clod.depClodSet.add(this);
  }

  unDepClod(Clod clod) {
    clod.depClodSet.remove(this);
  }

  callDepUpdates() {
    for (var callback in depUpdateSet) {
      callback();
    }
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

  static clone() {}
}

class ClodVisitor<T> {
  Clod<ClodValueType<T>> clod;

  Function(T value)? onGet;

  T value() {
    final T value;

    if (clod is NormalClod) {
      value = (clod as NormalClod).current;
    } else if (clod is PickClod) {
      value = (clod as PickClod).pick();
    } else {
      throw UnsupportedError(
          'Unsupport to get value of this clod. ${clod.key}');
    }
    if (onGet is Function) {
      onGet!(value);
    }
    return value;
  }

  ClodVisitor(this.clod, {this.onGet});
}

class ClodController<T> {
  Clod<ClodValueType<T>> clod;
  set(T value) {
    if (clod is NormalClod) {
      (clod as NormalClod).make(value);
    } else if (clod is MakeClod) {
      (clod as MakeClod).make(value);
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
  T? lastValue;

  T get current {
    if (lastValue == null) {
      throw Exception('PickClod is not initialized.');
    }
    return (lastValue as T);
  }

  ClodVisitor<V> visitorGenerate<V>(Clod<ClodValueType<V>> clod) {
    return ClodVisitor(clod, onGet: (_) => depClod(clod));
  }

  pick() {
    final valueAfter = meta.value(visitorGenerate);
    updateValue(valueAfter);
    return valueAfter;
  }

  updateValue(T value) {
    final equal = meta.equal ?? commonEqual;
    if (lastValue == null || !equal(current, value)) {
      lastValue = value;
      update();
    }
  }

  PickClod(super.value);
}

class MakeClod<T> extends Clod<ClodMakeValue<T>> {
  ClodVisitor<V> visitorGenerate<V>(Clod<ClodValueType<V>> clod) {
    return ClodVisitor(clod, onGet: (_) => depClod(clod));
  }

  ClodController<V> controllerGenerate<V>(Clod<ClodValueType<V>> clod) {
    return ClodController(clod);
  }

  make(T value) {
    meta.value(value, visitorGenerate, controllerGenerate);
  }

  MakeClod(super.value);
}
