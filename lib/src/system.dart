import 'package:get/get.dart';
import 'package:styx/src/mixins.dart';
import 'package:uuid/uuid.dart';

import './component.dart';
import './entity.dart';

// A function that takes JSON data and returns a component.
typedef ComponentDeserializerFunction = Component? Function(Map<String, dynamic> data);

// A function that takes a component and returns JSON-esque data.
typedef ComponentSerializerFunction = Map<String, dynamic> Function(SerializableComponent component);

// A function that takes in an entity and returns JSON-esque data.
typedef EntityToJsonFunction = Map<String, dynamic> Function(Entity entity);

// A function that takes in JSON and returns an Entity;
typedef EntityFromJsonFunction = Entity Function(Map<String, dynamic> json, EntitySystem system);

/// This system is for keeping track of all created entities.
class EntitySystem {
  EntitySystem() {
    /// If the list of entities changes, update the observable list.
    _refreshWorker = ever(_entities, refreshEntities);
  }

  final uuid = Uuid();

  /// Call this to release resources and workers.
  void dispose() {
    /// Clear entities.
    _entities.clear();
    entities.clear();

    /// Release workers
    _refreshWorker.dispose();
  }

  /// Remove all entities.
  void flush() {
    _entities.forEach((key, value) => value()!.destroy());
    _entities.clear();
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

  /// The refresh worker.
  late Worker _refreshWorker;

  /// An observable list of all entities.
  final _entities = Map<String, Rx<Entity>>().obs;

  /// An observable, unmodifiable list of them.
  final entities = <Rx<Entity>>[].obs;

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

  /// Refreshing the observable list of entities.
  void refreshEntities(Map<String, Rx<Entity>> ents) {
    entities.assignAll(ents.values);
  }

  /// The way a new entity should be created.
  Entity create() {
    final entity = Entity(uuid.v4(), this);
    _entities[entity.guid] = entity.obs;
    return entity;
  }

  /// Deserializing entities from JSON.
  Entity createFromJson(Map<String, dynamic> json) {
    final entity = entityFromJsonFunction(json, this);
    _entities[entity.guid] = entity.obs;
    return entity;
  }

  /// Standard serializer that turns an entity into JSON.
  Map<String, dynamic> entityToJson(Entity entity) {
    List<Map<String, dynamic>> componentData = [];
    entity.components().forEach(
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

  /// When an entity has been destroyed, we remove it from the list
  /// and that will automatically sync that to the observable list.
  void destroyed(Entity entity) {
    _entities.remove(entity.guid);
  }
}

/// Standard serializer that turns an entity into JSON.
Map<String, dynamic> defaultEntityToJsonFunction(Entity entity) {
  List<Map<String, dynamic>> componentData = [];
  entity.components().forEach(
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
    comps.forEach((dynamic compData) {
      final data = compData as Map<String, dynamic>;
      Component? c = componentFromJson(data);
      // if not contained in default system, check serializers.
      if (c == null) {
        system.deserializers.forEach((serializer) {
          if (c == null) {
            c = serializer.call(data);
          }
        });
      }

      /// If we actually got a component, add it.
      if (c != null) {
        e += c!;
      }
    });
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
