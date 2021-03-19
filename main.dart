import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styx/styx.dart';

final system = EntitySystem();

void main() {
  var entity = system.create();
  entity += Counter(0);
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entity = system.entities.where((e) => e.has<Counter>()).toList().first;
    return Scaffold(
      appBar: AppBar(title: Text('Counter Example')),
      body: Obx(() => Text(entity.get<Counter>().count().toString())),
      floatingActionButton: FloatingActionButton(
        onPressed: entity.get<Counter>().increment,
      ),
    );
  }
}

class Counter extends Component {
  Counter(int initial) {
    this.count(initial);
  }

  final count = 0.obs;

  void increment() {
    count(count() + 1);
  }

  void decrement() {
    count(count() - 1);
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "count": count(),
    };
  }
}
