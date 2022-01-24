import 'package:flutter/material.dart';
import 'package:styx/styx.dart';

final system = EntitySystem();

void main() {
  // ignore: unused_local_variable
  var entity = system.create();
  entity += Counter(0);
  entity += Name('Flutter');
  runApp(const Entry());
}

class Entry extends StatelessWidget {
  const Entry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  final EntityMatcher counterMatcher = const EntityMatcher(any: {Counter});
  final EntityMatcher personMatcher = const EntityMatcher(any: {Name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<List<Entity>>(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final counter = snapshot.data!.firstWhere(counterMatcher.matches);
                return StreamBuilder<int>(
                  stream: counter.get<Counter>().value.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('Counter: ${counter.get<Counter>().value()}');
                    } else {
                      return const Text('Loading...');
                    }
                  },
                );
              }

              return const SizedBox.shrink();
            },
            stream: system.entities.stream,
          ),
          StreamBuilder<List<Entity>>(
            stream: system.entities.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final person = snapshot.data!.firstWhere(personMatcher.matches);
                final counter = snapshot.data!.firstWhere(counterMatcher.matches);
                return Column(
                  children: [
                    StreamBuilder(
                      stream: counter.get<Counter>().value.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('Counter: ${counter.get<Counter>().value()}');
                        } else {
                          return const Text('Loading...');
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: person.get<Name>().value(),
                      onChanged: (value) => person.get<Name>().value(value),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<List<Entity>>(
        stream: system.entities.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final counter = snapshot.data!.firstWhere(counterMatcher.matches);
            return FloatingActionButton(
              onPressed: counter.get<Counter>().increment,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class Counter extends Component {
  Counter(int initial) {
    value(initial);
  }

  final value = 0.bs;

  @override
  void onRemoved() {
    value.close();
  }

  void increment() {
    value(value() + 1);
  }

  void decrement() {
    value(value() - 1);
  }
}

class Name extends Component {
  Name(String initial) {
    value(initial);
  }

  final value = ''.bs;

  @override
  void onRemoved() {
    value.close();
  }
}
