import 'package:clodx/main.dart';
import 'package:flutter/material.dart';

final countClod = clod(0, equal: (prev, next) {
  return next > 15;
});

final pickCountClod = pickClod((visit) {
  return visit(countClod).value();
});

final pickCountClod2 = pickClod((visit) {
  return visit(countClod).value();
}, equal: (prev, next) {
  return next < 10;
});

final pickCountClod3 = pickClod((visit) {
  return visit(pickCountClod2).value();
});

final makeCountClod = makeClod<int>((value, visit, control) {
  final count = visit(countClod).value();
  final setCount = control(countClod).set;

  setCount(count + value);
});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ClodState<MyHomePage> {
  void _incrementCounter() {
    final setCount = useSetClod(makeCountClod);
    setCount(1);
  }

  @override
  Widget build(BuildContext context) {
    final count = useClodValue(pickCountClod2);
    final count2 = useClodValue(countClod);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count $count2',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
