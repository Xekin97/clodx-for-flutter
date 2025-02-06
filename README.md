# clodx_for_flutter

面向 Flutter 应用程序的 clodx 轻量原子化状态管理工具。

# Run in playground

```
cd playground
flutter pub get
```

# Functions

```dart
import 'package:clodx/main.dart';

final countClod = clod(0);

// The type of this is PickClod<int>
final countPickClod = pickClod((visit) {
    return visit(countClod).value();
});

// The type of this is PickClod<int>
final countPlusPickClod = pickClod((visit) {
    return visit(countClod).value() + 1;
});

final makeCountClod = makeClod<int>((value, visit, control) {
    final set = control(countClod).set;
    set(value);
})

final doubleCountClod = makeClod((_, visit, control) {
    final set = control(countClod).set;
    final current = visit(countClod).value();
    set(current * 2);
})

void main () {
    final count = visitClod(countClod);
    final setCount = controlClod(countClod).set;
    // count is 0
    print(count);
    setCount(1);
    // count is 1
    print(count);
};
```

# Usage in Component

```dart
import 'package:clodx/main.dart';
class Counter extends StatefulWidget {
    const Counter({ super.key });
    @override
    State<Counter> createState() => _CounterState();
}

// use `ClodState` class to instead `State` class
class _CounterState extends ClodState<Counter> {

    int get count {
        final count = useClodValue(countClod);
        return count;
    }

    int get countPlus {
        final count = useClodValue(countPlusPickClod);
        return count;
    }

    setCount(int value) {
        final setCount = useSetClod(countClod);
        setCount(value);
    }

    plusCount() {
        setCount(count + 1);
    }

    @override
    Widget build (BuildContext context) {

        return
        ...
        Text(count.toString()),
        Text(countPlus.toString()),
        TextButton(..., onPressed: plusCount),
        ...
    }
}

// or use `useClod`
class _CounterState extends ClodState<Counter> {

    @override
    Widget build (BuildContext context) {
        final (count, setCound) = useClod(countClod)

        return
        ...
        Text(count.toString()),
        TextButton(..., onPressed: () {
            setCount(count + 1);
        }),
        ...
    }
}

```
