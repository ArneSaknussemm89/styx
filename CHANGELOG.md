## [1.3.2] - 24/06/2021

Fixed:
- A bug where listening to the entity list would send two events, one with an empty
list and one with the actual changed list. This was causing strange behavior for listeners.

## [1.3.1] - 23/06/2021

Fixed:
- Extensions were not being exported and could not be used.

New:
- Added a `styx` extension for any `Rx<T>` type for ease of use for reactive widgets.
```
class Person {
  Person({String title = ''}) {
    this.title(title);
  }

  final title = ''.obs;
}

final person = Person(title: "Name");

/// Then inside a widget somewhere.
person.title.styx((value) {
  return Text(value);
})
```

## [1.3.0] - 23/06/2021

BREAKING CHANGES:
- EntitySystem and EntityMatcher updated to expect `Rx<Entity>` instead of `Entity` directly
as the `Rx<T>` functionality was expected in various places.

This will be changed in 2.0.0 as Entity itself will implement Rx directly and won't
need to be wrapped with `Rx<T>`.

## [1.2.1] - 22/06/2021

Fixes:
- `guid` was missing from Entity `props`, which could cause two different entities
with matching components and values to match even though they have different
guids.

## [1.2.0] - 21/06/2021

Additions:
- Added a new EntityMatcher class that can be used to describe a way of
matching entities. Can be used on it's own to create your own grouping of entities
and will be used in the Flutter specific package for Styx.
- Added a new method `hasComponent` for when the Type is not explicity known.

## [1.1.0] - 27/03/2021

Full release! Matched to Get ^4.1.0
Additions:
- Added a new method for getting component differences between two entities.

## [1.0.0-nullsafety.6] - 19/03/2021

Fixing an issue where the entityToJsonFunction was not being used.

## [1.0.0-nullsafety.5] - 19/03/2021

Fixing pub.dev warnings and gradings.

## [1.0.0-nullsafety.4] - 19/03/2021

Fixed an issue with a circular call between `Entity` and `EntitySystem` that was causing a
StackOverflow error.

## [1.0.0-nullsafety.3] - 19/03/2021

Fixed an issue with json_serializable that was picking up on the `fromJson` factory on `Entity`.

## [1.0.0-nullsafety.2] - 19/03/2021

Added a serializable component mixin.

## [1.0.0-nullsafety.1] - 19/03/2021

Fixed small nits with README.

## [1.0.0-nullsafety.0] - 19/03/2021

Initial release with basic structure.
