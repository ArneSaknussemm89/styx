import 'package:equatable/equatable.dart';

import 'component.dart';
import 'extensions/extensions.dart';
import 'system.dart';

/// A container that holds components essentially.
class Entity with EquatableMixin {
  Entity(this.guid, this.system);

  final String guid;

  /// The system where this entity is contained.
  final EntitySystem system;

  // Holding all components map through their type.
  final components = <Type, Component>{}.bs;

  /// Used internally for verifying Entity has not been destroyed before
  /// mutating any values.
  final isDestroyed = false.bs;

  /// Returns a matching component from type T.
  T get<T extends Component>() {
    var component = components.value[T];
    return component as T;
  }

  /// Adds component to the entity.
  Entity operator +(Component component) {
    assert(!isDestroyed.value, 'Tried adding component to destroyed entity: ${toJson()}');
    final copy = Map<Type, Component>.from(components.value);
    // Create new list and then add.
    copy[component.runtimeType] = component..ref = this;
    components.add(copy);
    // Call onAdded.
    component.onAdded();
    return this;
  }

  /// For cascade
  void set(Component component) {
    var _ = this + component;
  }

  /// Removes component from the entity.
  Entity operator -(Type t) {
    assert(isDestroyed.value, 'Tried removing component from destroyed entity: ${toJson()}');
    var component = components.value[t];
    if (component != null) {
      // Call onRemoved.
      component.onRemoved();
      final copy = Map<Type, Component>.from(components.value);
      // Created copy and removed this component.
      copy.remove(t);
      // Set value of the subject.
      components.add(copy);
    }

    return this;
  }

  /// For cascade
  void remove<T extends Component>() {
    var _ = this - T;
  }

  /// If entity has a component of type T
  bool has<T extends Component>() {
    return components.value.containsKey(T);
  }

  /// Checks if entity has a component of the type of the given object.
  bool hasComponent(Type type) {
    return components.value.containsKey(type);
  }

  /// Destroy an entity which will lead to following steps:
  /// 1. Remove all components
  /// 2. Remove from the system
  /// 3. Set `isDestroyed` to `true`
  void destroy() {
    for (var comp in components.value.values.toList()) {
      var _ = this - comp.runtimeType;
    }
    system.destroyed(this);
    // Add to sink that we are destroyed.
    isDestroyed.add(true);
    isDestroyed.close();
  }

  /// Compares the component list between entities and returns a list of
  /// types of components that "a" has that "b" does not.
  ///
  /// E.g.
  ///
  /// final compared = a.componentDiff(b);
  Set<Type> componentDiff(Entity e) {
    final ecomps = e.components.value.keys.toSet();
    return components.value.keys.toSet().difference(ecomps);
  }

  Map<String, dynamic> toJson() {
    return system.entityToJson(this);
  }

  static Entity fromJson(Map<String, dynamic> json, EntitySystem system) {
    return system.createFromJson(json);
  }

  @override
  List<Object> get props => [guid, components];
}

/// A class that describe a way to filter entities.
///
/// There are 3 properties, each with it's own functionality.
/// all: The entity MUST contain all of these components.
/// any: The entity MUST contain at *least* one of these components.
/// inverse: Flips the logic, so MUST becomes MUST NOT.
///
/// var matcher = EntityMatcher(all: [CountComponent, PriceComponent])
/// This matcher would match any entity that has both the CountComponent AND the
/// Price Component.
///
/// var matcher = EntityMatcher(all: [CartComponent], any: [PriceComponent, CouponComponent])
/// This matcher would match any entity that has the CartComponent, and has at least one between
/// the PriceComponent and CouponComponent.
///
/// var matcher = EntityMatcher(all: [DiscontinuedComponent, PriceComponent], reverse: true)
/// This matcher would match any entity that DOES NOT have the DiscontinuedComponent and PriceComponent.
///
/// var matcher = EntityMatcher(any: [DiscontinuedComponent, OutOfStockComponent, DisabledComponent], reverse: true)
/// This matcher would match any entity that DOES NOT have any one of these components.
class EntityMatcher extends Equatable {
  const EntityMatcher({
    this.all = const {},
    this.any = const {},
    this.reverse = false,
  });

  final Set<Type> all;
  final Set<Type> any;
  final bool reverse;

  bool contains(Type type) {
    return all.contains(type) || any.contains(type);
  }

  bool matches(Entity entity) {
    if (any.isEmpty && all.isEmpty) {
      return true;
    }

    final anyMatched = matchesAny(entity);
    final allMatched = matchesAll(entity);

    return anyMatched && allMatched;
  }

  bool matchesAll(Entity entity) {
    if (all.isEmpty) return true;
    // If reverse, we want to make sure we contain NONE of the components
    // in all.
    if (reverse) {
      for (final t in all) {
        if (entity.hasComponent(t)) {
          return false;
        }
      }
    } else {
      for (final t in all) {
        if (!entity.hasComponent(t)) {
          return false;
        }
      }
    }

    return true;
  }

  bool matchesAny(Entity entity) {
    if (any.isEmpty) return true;
    // If reversed, we match if it doesn't contain any of the any components
    if (reverse) {
      for (var t in any) {
        if (entity.hasComponent(t) == false) {
          return true;
        }
      }
    } else {
      for (var t in any) {
        if (entity.hasComponent(t)) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  List<Object?> get props => [all, any, reverse];
}
