import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

import './component.dart';
import './system.dart';

extension RxImplEntity on Rx<Entity> {
  /// Returns a matching component from type T.
  T get<T extends Component>() {
    var component = value.components[T];
    return component as T;
  }

  /// Adds component to the entity.
  Entity operator +(Component component) {
    assert(value.isDestroyed.isFalse,
        'Tried adding component to destroyed entity: ${toJson()}');
    value.components[component.runtimeType] = component..ref = value;
    return value;
  }

  /// For cascade
  void set(Component component) {
    var _ = this + component;
  }

  /// Removes component from the entity.
  Entity operator -(Type t) {
    assert(value.isDestroyed.isFalse,
        'Tried removing component from destroyed entity: ${toJson()}');
    var component = value.components[t];
    if (component != null) {
      value.components.remove(t);
    }

    return value;
  }

  /// For cascade
  void remove<T extends Component>() {
    var _ = this - T;
  }

  /// If entity has a component of type T
  bool has<T extends Component>() {
    return value.components.containsKey(T);
  }
}

extension RxnImplEntity on Rxn<Entity> {
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
}

/// A container that holds components essentially.
class Entity with EquatableMixin {
  Entity(this.guid, this.system);

  final String guid;

  /// The system where this entity is contained.
  final EntitySystem system;

  // Holding all components map through their type.
  RxMap<Type, Component> components = <Type, Component>{}.obs;

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
  Set<Type> componentDiff(Entity e) {
    final ecomps = e.components.keys.toSet();
    return components.keys.toSet().difference(ecomps);
  }

  Map<String, dynamic> toJson() {
    return system.entityToJson(this);
  }

  factory Entity.fromJson(Map<String, dynamic> json, EntitySystem system) {
    return system.createFromJson(json);
  }

  @override
  List<Object> get props => [components];
}
