import 'package:flutter/material.dart';

import 'main.dart';

abstract class ClodState<Widget extends StatefulWidget> extends State<Widget> {
  final Set<Clod> _clods = {};
  final Set<dynamic> _functionCacheSet = {};
  final Map<String, dynamic> _clodSetterCache = {};

  _update() {
    setState(() {});
  }

  _memorizesClod(Clod clod) {
    _clods.add(clod);
    clod.depUpdate(this._update);
  }

  _unMemorizeClod(Clod clod) {
    clod.unDepUpdate(this._update);
  }

  _once(void Function() func) {
    if (_functionCacheSet.contains(func)) {
      return;
    }
    _functionCacheSet.add(func);
    func();
  }

  (T, void Function(T value)) useClod<T>(Clod<ClodValueType<T>> clod) {
    return (useClodValue(clod), useSetClod(clod));
  }

  void Function(T value) useSetClod<T>(Clod<ClodValueType<T>> clod) {
    if (clod is MakeClod) {
      _clodSetterCache[clod.key] = (clod as MakeClod).make;
    } else if (clod is NormalClod) {
      _clodSetterCache[clod.key] = (clod as NormalClod).make;
    } else {
      throw Exception(
          "Can not set clod value to which except NormalClod or MakeClod.");
    }

    return _clodSetterCache[clod.key];
  }

  T useClodValue<T>(Clod<ClodValueType<T>> clod) {
    if (clod is MakeClod) {
      throw Exception(
          "Can not get clod value from which except NormalClod or PickClod.");
    }

    _memorizesClod(clod);

    if (clod is PickClod) {
      _once((clod as PickClod).pick);
    }

    return visitClod(clod).value();
  }

  @override
  void dispose() {
    _functionCacheSet.clear();
    _clodSetterCache.clear();

    for (var clod in _clods) {
      _unMemorizeClod(clod);
    }
    _clods.clear();

    super.dispose();
  }
}
