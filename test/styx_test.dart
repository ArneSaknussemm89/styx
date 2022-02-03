import 'package:flutter_test/flutter_test.dart';

import 'package:styx/styx.dart';

import 'data/data.dart';

void main() {
  group('Adding Components', () {
    test('can add component', () {
      final system = EntitySystem<String>();
      var entity = system.create();

      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count.value, 0);
    });

    test('cannot have same component twice', () {
      final system = EntitySystem<String>();
      var entity = system.create();

      entity += CountComponent(0);
      expect(entity.get<CountComponent>().count.value, 0);
      entity += CountComponent(1);
      expect(entity.get<CountComponent>().count.value, 1);
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
      expect(diff, {CountComponent});
    });

    test('different entities with same values', () {
      final system = EntitySystem();

      var e1 = system.create();
      e1 += CountComponent(1);

      var e2 = system.create();
      e2 += CountComponent(1);

      expect(e1 == e2, false);
    });
  });

  group('Matchers', () {
    test('matching all', () {
      final system = EntitySystem();

      const cartMatcher = EntityMatcher(all: {CartComponent, PriceComponent});
      const itemMatcher = EntityMatcher(all: {PriceComponent, CatalogItemComponent});

      var e1 = system.create();
      var e2 = system.create();
      var e3 = system.create();

      e1 += CatalogItemComponent();
      e1 += PriceComponent(2.00);

      e2 += CatalogItemComponent();
      e2 += PriceComponent(5.00);

      e3 += PriceComponent(10.00);
      e3 += CartComponent();

      // Entity should match to itemMatcher but NOT to cartMatcher
      expect(cartMatcher.matches(e1), false);
      expect(itemMatcher.matches(e1), true);

      expect(cartMatcher.matches(e2), false);
      expect(itemMatcher.matches(e2), true);

      expect(cartMatcher.matches(e3), true);
      expect(itemMatcher.matches(e3), false);
    });

    test('testing any', () {
      final system = EntitySystem();

      const itemMatcher = EntityMatcher(any: {PriceComponent, CatalogItemComponent});

      var e1 = system.create();
      var e2 = system.create();
      var e3 = system.create();

      e1 += CatalogItemComponent();

      e2 += PriceComponent(5.00);

      e3 += CountComponent(1);
      e3 += NameComponent('Test');

      expect(itemMatcher.matches(e1), true);
      expect(itemMatcher.matches(e2), true);
      expect(itemMatcher.matches(e3), false);
    });

    test('testing any inverse', () {
      final system = EntitySystem();

      const itemMatcher = EntityMatcher(any: {PriceComponent, CatalogItemComponent}, reverse: true);

      var e1 = system.create();
      var e2 = system.create();
      var e3 = system.create();

      e1 += CatalogItemComponent();

      e2 += PriceComponent(5.00);

      e3 += PriceComponent(1.00);
      e3 += CatalogItemComponent();

      expect(itemMatcher.matches(e1), true);
      expect(itemMatcher.matches(e2), true);
      expect(itemMatcher.matches(e3), false);
    });

    test('testing all inverse', () {
      final system = EntitySystem();

      const itemMatcher = EntityMatcher(all: {PriceComponent, CatalogItemComponent}, reverse: true);

      var e1 = system.create();
      var e2 = system.create();
      var e3 = system.create();

      e1 += CatalogItemComponent();

      e2 += PriceComponent(5.00);

      e3 += NameComponent('Test');

      expect(itemMatcher.matches(e1), false);
      expect(itemMatcher.matches(e2), false);
      expect(itemMatcher.matches(e3), true);
    });
  });

  group('Reactivity', () {
    test('detect new entities', () async {
      final system = EntitySystem();

      var count = 0;

      final subscription = system.entities.listen((value) {
        count = value.length;
      });

      // ignore: unused_local_variable
      var e = system.create();
      await Future.delayed(const Duration(seconds: 1));
      expect(count, 1);
      // ignore: unused_local_variable
      var e2 = system.create();
      await Future.delayed(const Duration(seconds: 1));
      expect(count, 2);

      subscription.cancel();
    });
  });
}
