import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styx/styx.dart';

final system = EntitySystem();

void main() {
  var entity = system.create();
  entity += Counter(0);
  entity += Name('Flutter');
  runApp(Entry());
}

class Entry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = system.entities.where((e) => e.has<Counter>()).toList().first;
    final person = system.entities.where((e) => e.has<Name>()).toList().first;
    return Scaffold(
      appBar: AppBar(title: Text('Counter Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return Center(
              child: Text(
                counter.get<Counter>().value().toString(),
                style: TextStyle(fontSize: 30),
              ),
            );
          }),
          Obx(() {
            return Center(
              child: Text(person.get<Name>().value() ?? '', style: TextStyle(fontSize: 24)),
            );
          }).paddingOnly(top: 20),
          TextFormField(
            initialValue: person.get<Name>().value(),
            onChanged: (value) => person.get<Name>().value(value),
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.get<Counter>().increment,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Counter extends Component {
  Counter(int initial) {
    this.value(initial);
  }

  final value = 0.obs;

  void increment() {
    value(value() + 1);
  }

  void decrement() {
    value(value() - 1);
  }
}

class Name extends Component {
  Name(String initial) {
    this.value(initial);
  }

  final value = ''.obs;
}
