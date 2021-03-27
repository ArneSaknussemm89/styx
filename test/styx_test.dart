import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:styx/styx.dart';

import 'data/data.dart';

void main() {
  group('Adding Components', () {
    test('can add component', () {
      final system = EntitySystem();

      expect(system.entities.length, 0);
      var entity = system.create();
      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count(), 0);
    });

    test('cannot have same component twice', () {
      final system = EntitySystem();

      expect(system.entities.length, 0);
      var entity = system.create();
      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count(), 0);
      entity += CountComponent(1);
      expect(entity.get<CountComponent>().count(), 1);
    });
  });

  group('Comparisons', () {
    test('find component differences', () {
      final system = EntitySystem();

      var e1 = system.create();
      e1 += CountComponent(1);

      var e2 = system.create();
      e2 += NameComponent('Entity 2');

      final diff = e1.componentDiff(e2);
      expect(diff, Set.from([CountComponent]));
    });
  });

  group('Reactivity', () {
    test('detect new entities', () {
      final system = EntitySystem();

      List<String> guids = [];
      Worker watcher = ever(system.entities, (List<Rx<Entity>> entities) {
        guids = entities.map((e) => e().guid).toList();
      });

      var e = system.create();
      var e2 = system.create();

      expect(guids.length, 2);
      watcher.dispose();
    });
  });
}
