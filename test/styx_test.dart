import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:styx/styx.dart';

class CountComponent extends Component {
  CountComponent(int count) {
    this.count(count);
  }

  final count = RxInt(0);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "count": count(),
    };
  }
}

void main() {
  late EntitySystem system;

  setUp(() {
    system = EntitySystem();
  });

  group('Adding Components', () {
    /// Clean entities between tests.
    tearDown(() {
      system.flush();
    });

    test('can add component', () {
      expect(system.entities.length, 0);
      var entity = system.create();
      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count(), 0);
    });

    test('cannot have same component twice', () {
      expect(system.entities.length, 0);
      var entity = system.create();
      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count(), 0);
      entity += CountComponent(1);
      expect(entity.get<CountComponent>().count(), 1);
    });
  });

  group('Reactivity', () {
    /// Clean entities between tests.
    Worker? watcher;

    tearDown(() {
      system.flush();
      watcher?.dispose();
    });

    test('detect new entities', () {
      List<String> guids = [];
      watcher = ever(system.entities, (List<Rx<Entity>> entities) {
        guids = entities.map((e) => e()!.guid).toList();
      });

      var e = system.create();
      var e2 = system.create();

      expect(guids.length, 2);
    });
  });
}
