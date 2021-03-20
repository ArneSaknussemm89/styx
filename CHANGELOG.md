## [1.0.0-nullsafety.4]  19/03/2021

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
