import 'dart:async';

import 'package:uuid/uuid.dart';

import 'component.dart';
import 'entity.dart';
import 'extensions/extensions.dart';
import 'mixins.dart';

// A function that takes JSON data and returns a component.
typedef ComponentDeserializerFunction = Component? Function(Map<String, dynamic> data);

// A function that takes a component and returns JSON-esque data.
typedef ComponentSerializerFunction = Map<String, dynamic> Function(SerializableComponent component);

// A function that takes in an entity and returns JSON-esque data.
typedef EntityToJsonFunction = Map<String, dynamic> Function(Entity entity);

// A function that takes in an entity and returns T which would be a value
// that can be used to determine if an entity is unique.
typedef EntityUniqueKeyGeneratorFunction<T> = T Function(Entity entity);

// A function that takes in JSON and returns an Entity;
typedef EntityFromJsonFunction = Entity Function(
  Map<String, dynamic> json,
  EntitySystem system,
);

/// This system is for keeping track of all created entities.
class EntitySystem<T> {
  final uuid = const Uuid();

  // The listener that updates the public list of entities.
  late StreamSubscription _listener;

  EntityUniqueKeyGeneratorFunction<T>? uniqueKeyGeneratorFunction;

  EntitySystem() {
    // When entities updates, map over and update the public entity list.
    _listener = _entities.stream.listen((ents) {
      final list = ents.values.toList();
      entities.add(list);
    });
  }

  // Generate a system with a custom unique key generator function.
  static EntitySystem<T> withUniqueKeyGenerator<T>(
    EntityUniqueKeyGeneratorFunction<T> uniqueKeyGeneratorFunction,
  ) {
    final system = EntitySystem<T>();
    system.uniqueKeyGeneratorFunction = uniqueKeyGeneratorFunction;
    return system;
  }

  /// A list of registered deserializer functions.
  List<ComponentDeserializerFunction> deserializers = [
    componentFromJson,
  ];

  /// A list of registered serializer functions.
  List<ComponentSerializerFunction> serializers = [
    componentToJson,
  ];

  /// The function called to turn an entity into JSON.
  EntityToJsonFunction entityToJsonFunction = defaultEntityToJsonFunction;

  /// The function called to turn JSON into an entity;
  EntityFromJsonFunction entityFromJsonFunction = defaultEntityFromJsonFunction;

  /// The internal registry of all created entities.
  final _entities = <T, Entity>{}.bs;

  /// An observable list of entities.
  final entities = <Entity>[].bs;

  /// Call this to release resources and workers.
  void dispose() {
    /// Clear entities and cancel subscription.
    _listener.cancel();
    _entities.close();
    entities.close();
  }

  /// Remove all entities.
  void flush() {
    if (_entities.hasValue) {
      _entities.value.forEach((guid, e) => e.destroy());
      _entities.value.clear();
    }
  }

  /// Register a deserializer function.
  void registerDeserializer(ComponentDeserializerFunction deserializer) {
    if (!deserializers.contains(deserializer)) {
      deserializers.add(deserializer);
    }
  }

  /// Register a serializer function.
  void registerSerializer(ComponentSerializerFunction serializer) {
    if (!serializers.contains(serializer)) {
      serializers.add(serializer);
    }
  }

  /// The way a new entity should be created.
  Entity create() {
    final entity = Entity(uuid.v4(), this);
    return setEntity(entity);
  }

  /// Deserializing entities from JSON.
  Entity createFromJson(Map<String, dynamic> json) {
    final entity = entityFromJsonFunction(json, this);
    return setEntity(entity);
  }

  /// This function actually sets the entity in the list.
  /// Left public so that if you want to use your own method for creating entities
  /// you can, as long as you call this method so the system tracks the entity.
  Entity setEntity(Entity entity) {
    final current = _entities.value;
    // If we have a custom key generator use that.
    late final T key;
    if (uniqueKeyGeneratorFunction != null) {
      key = uniqueKeyGeneratorFunction!(entity);
    } else {
      key = entity.guid as T;
    }
    final newList = Map.fromIterables([...current.keys, key], [...current.values, entity]);
    _entities.add(newList);
    // Return the entity.
    return _entities.value[entity.guid]!;
  }

  /// Standard serializer that turns an entity into JSON.
  Map<String, dynamic> entityToJson(Entity entity) {
    return entityToJsonFunction(entity);
  }

  /// When an entity has been destroyed, we remove it from the list
  /// and that will automatically sync that to the observable list.
  void destroyed(Entity entity) {
    final current = _entities.value;
    // Drop the guid and remove the entity from the list.
    final newList = Map.fromIterables([...current.keys], [...current.values].where((e) => e != entity));
    // Set the new list.
    _entities.add(newList);
  }
}

/// Standard serializer that turns an entity into JSON.
Map<String, dynamic> defaultEntityToJsonFunction(Entity entity) {
  List<Map<String, dynamic>> componentData = [];
  entity.components.value.forEach(
    (type, component) {
      if (component is SerializableComponent) {
        componentData.add({'type': type.toString(), 'data': (component as SerializableComponent).toJson()});
      }
    },
  );
  return <String, dynamic>{
    'components': componentData,
  };
}

Entity defaultEntityFromJsonFunction(Map<String, dynamic> json, EntitySystem system) {
  var e = Entity(json['guid'], system);
  if (json['components'] != null) {
    final comps = json['components'] as List<dynamic>;
    for (var compData in comps) {
      final data = compData as Map<String, dynamic>;
      Component? c = componentFromJson(data);
      // if not contained in default system, check serializers.
      if (c == null) {
        for (var serializer in system.deserializers) {
          c = serializer.call(data);
        }
      }

      /// If we actually got a component, add it.
      if (c != null) {
        e += c;
      }
    }
  }

  return e;
}

/// A map of strings to types.
Component? componentFromJson(Map<String, dynamic> json) {
  return null;
}

Map<String, dynamic> componentToJson(SerializableComponent component) {
  return component.toJson();
}
