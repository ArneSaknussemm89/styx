import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:styx/styx.dart';

final system = EntitySystem();

void main() {
  // ignore: unused_local_variable
  var entity = system.create();
  entity += Counter(0);
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // The matcher for our entities.
  final matcher = const EntityMatcher(any: {Counter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: StreamBuilder<List<Entity>>(
        stream: system.entities.stream,
        builder: (context, snapshot) {
          final hasData = snapshot.hasData;
          if (!hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entities = snapshot.data;
          final counters = entities!.where(matcher.matches).toList();

          return StreamBuilder<int>(
            stream: counters.first.get<Counter>().count.stream,
            builder: (context, snap) {
              return snap.hasData ? Text(snap.data.toString()) : const Text('No data');
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<Entity>>(
        stream: system.entities.stream,
        builder: (context, snapshot) {
          final hasData = snapshot.hasData;
          if (!hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entities = snapshot.data;
          final counters = entities!.where(matcher.matches).toList();

          return counters.isNotEmpty
              ? FloatingActionButton(
                  onPressed: counters.first.get<Counter>().increment,
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class Counter extends Component {
  Counter(int initial) {
    count = BehaviorSubject.seeded(initial);
  }

  late BehaviorSubject<int> count;

  @override
  void onRemoved() {
    count.close();
  }

  void increment() {
    count(count() + 1);
  }

  void decrement() {
    count(count() - 1);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "count": count(),
    };
  }
}
