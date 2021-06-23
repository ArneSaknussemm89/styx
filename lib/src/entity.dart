import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

import 'component.dart';
import 'system.dart';

extension RxImplEntity on Rx<Entity> {
  RxMap<Type, Component> get components => value.components;

  /// Returns a matching component from type T.
  T get<T extends Component>() {
    var component = value.components[T];
    return component as T;
  }

  /// Adds component to the entity.
  Rx<Entity> operator +(Component component) {
    assert(value.isDestroyed.isFalse,
        'Tried adding component to destroyed entity: ${toJson()}');
    update((val) {
      val!.components[component.runtimeType] = component..ref = val;
    });
    return this;
  }

  /// For cascade
  void set(Component component) {
    var _ = this + component;
  }

  /// Removes component from the entity.
  Rx<Entity> operator -(Type t) {
    assert(value.isDestroyed.isFalse,
        'Tried removing component from destroyed entity: ${toJson()}');
    var component = value.components[t];
    if (component != null) {
      update((val) {
        val!.components.remove(t);
      });
    }

    return this;
  }

  /// For cascade
  void remove<T extends Component>() {
    var _ = this - T;
  }

  /// If entity has a component of type T
  bool has<T extends Component>() {
    return value.components.containsKey(T);
  }

  bool hasComponent(Type type) {
    return value.components.containsKey(type);
  }

  /// Compares the component list between entities and returns a list of
  /// types of components that "a" has that "b" does not.
  ///
  /// E.g.
  ///
  /// final compared = a.componentDiff(b);
  Set<Type> componentDiff(Rx<Entity> e) {
    return value.componentDiff(e);
  }
}

extension RxnImplEntity on Rxn<Entity> {
  RxMap<Type, Component>? get components =>
      value != null ? value!.components : null;

  /// Returns a matching component from type T.
  T? get<T extends Component>() {
    var component = value?.components[T];
    return component as T;
  }

  /// Adds component to the entity.
  Entity? operator +(Component component) {
    if (value == null) return null;
    assert(
      value!.isDestroyed.isFalse,
      'Tried adding component to destroyed entity: ${toJson()}',
    );
    value!.components[component.runtimeType] = component..ref = value!;
    return value!;
  }

  /// For cascade
  void set(Component component) {
    var _ = this + component;
  }

  /// Removes component from the entity.
  Entity? operator -(Type t) {
    if (value == null) return null;
    assert(
      value!.isDestroyed.isFalse,
      'Tried removing component from destroyed entity: ${toJson()}',
    );
    var component = value!.components[t];
    if (component != null) {
      value!.components.remove(t);
    }

    return value;
  }

  /// For cascade
  void remove<T extends Component>() {
    var _ = this - T;
  }

  /// If entity has a component of type T
  bool? has<T extends Component>() {
    if (value == null) return null;
    return value!.components.containsKey(T);
  }

  /// Compares the component list between entities and returns a list of
  /// types of components that "a" has that "b" does not.
  ///
  /// E.g.
  ///
  /// final compared = a.componentDiff(b);
  Set<Type>? componentDiff(Rx<Entity> e) {
    if (value == null) return null;
    return value!.componentDiff(e);
  }
}

/// A container that holds components essentially.
class Entity with EquatableMixin {
  Entity(this.guid, this.system);

  final String guid;

  /// The system where this entity is contained.
  final EntitySystem system;

  // Holding all components map through their type.
  final components = <Type, Component>{}.obs;

  /// Used internally for verifying Entity has not been destroyed before
  /// mutating any values.
  final isDestroyed = false.obs;

  /// Returns a matching component from type T.
  T get<T extends Component>() {
    var component = components[T];
    return component as T;
  }

  /// Adds component to the entity.
  Entity operator +(Component component) {
    assert(isDestroyed.isFalse,
        'Tried adding component to destroyed entity: ${toJson()}');
    components[component.runtimeType] = component..ref = this;
    return this;
  }

  /// For cascade
  void set(Component component) {
    var _ = this + component;
  }

  /// Removes component from the entity.
  Entity operator -(Type t) {
    assert(isDestroyed.isFalse,
        'Tried removing component from destroyed entity: ${toJson()}');
    var component = components[t];
    if (component != null) {
      components.remove(t);
    }

    return this;
  }

  /// For cascade
  void remove<T extends Component>() {
    var _ = this - T;
  }

  /// If entity has a component of type T
  bool has<T extends Component>() {
    return components.containsKey(T);
  }

  /// Destroy an entity which will lead to following steps:
  /// 1. Remove all components
  /// 2. Remove from the system
  /// 3. Set `isDestroyed` to `true`
  void destroy() {
    for (var comp in components.values.toList()) {
      var _ = this - comp.runtimeType;
    }
    system.destroyed(this);
    isDestroyed.value = true;
  }

  /// Compares the component list between entities and returns a list of
  /// types of components that "a" has that "b" does not.
  ///
  /// E.g.
  ///
  /// final compared = a.componentDiff(b);
  Set<Type> componentDiff(Rx<Entity> e) {
    final ecomps = e.components.keys.toSet();
    return components.keys.toSet().difference(ecomps);
  }

  Map<String, dynamic> toJson() {
    return system.entityToJson(this);
  }

  static Rx<Entity> fromJson(Map<String, dynamic> json, EntitySystem system) {
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
  EntityMatcher({Set<Type>? all, Set<Type>? any, this.reverse = false})
      : all = all ?? Set.of([]),
        any = any ?? Set.of([]);

  final Set<Type> all;
  final Set<Type> any;
  final bool reverse;

  bool contains(Type type) {
    return all.contains(type) || any.contains(type);
  }

  bool matches(Rx<Entity> entity) {
    if (any.isEmpty && all.isEmpty) {
      return true;
    }

    final anyMatched = matchesAny(entity);
    final allMatched = matchesAll(entity);

    return anyMatched && allMatched;
  }

  bool matchesAll(Rx<Entity> entity) {
    if (all.isEmpty) return true;
    // If reverse, we want to make sure we contain NONE of the components
    // in all.
    if (reverse) {
      for (var t in all) {
        if (entity.hasComponent(t)) {
          return false;
        }
      }
    } else {
      for (var t in all) {
        if (entity.hasComponent(t) == false) {
          return false;
        }
      }
    }

    return true;
  }

  bool matchesAny(Rx<Entity> entity) {
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
