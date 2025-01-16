import 'package:flutter/material.dart';

import 'main.dart';

abstract class ClodState<Widget extends StatefulWidget> extends State<Widget> {
  final Set<Clod> _clods = {};
  final Set<dynamic> _functionCacheSet = {};
  final Map<String, dynamic> _clodSetterCache = {};

  _update() {
    setState(() {});
  }

  _memoryClod(Clod clod) {
    _clods.add(clod);
    clod.depUpdate(this._update);
  }

  _unMemoryClod(Clod clod) {
    _clods.remove(clod);
    clod.unDepUpdate(this._update);
  }

  _once(void Function() func) {
    if (_functionCacheSet.contains(func)) {
      return;
    }
    _functionCacheSet.add(func);
    func();
  }

  (T, void Function(T value)) useClod<T>(NormalClod<T> clod) {
    return (useClodValue(clod), useSetClod(clod));
  }

  void Function(T value) useSetClod<T>(NormalClod<T> clod) {
    if (_clodSetterCache.containsKey(clod.key)) {
      return _clodSetterCache[clod.key];
    }
    _clodSetterCache[clod.key] = clod.make;
    return clod.make;
  }

  T useClodValue<T>(NormalClod<T> clod) {
    _memoryClod(clod);
    return clod.current;
  }

  T usePickClod<T>(PickClod<T> clod) {
    _once(clod.pick);
    _memoryClod(clod);
    return clod.current as T;
  }

  useMakeClod<T>(MakeClod<T> clod) {
    return (T value) {
      clod.make(value);
    };
  }

  @override
  void dispose() {
    _functionCacheSet.clear();
    _clodSetterCache.clear();

    for (var clod in _clods) {
      _unMemoryClod(clod);
    }

    super.dispose();
  }
}
