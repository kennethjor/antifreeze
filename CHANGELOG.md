# Changelog

## 0.3.1 (dev)
* *API change:* Default model functions are supplied the values object rather than as context.
* *API change:* Model serialization now only encodes the `id` set using `id()`.

## 0.2.1 (2013-07-19)
* *Fix:* Thorough testing and related bugfixes to the `Collection`, `Set`, and `Map` classes.

## 0.2.0 (2013-07-10)
* *Feature:* Basic `Collection` implementation.
* *Feature:* Basic `Set` implementation.
* *Feature:* Basic `Map` implementation.
* *Feature:* Removed `Models` default recursive JSON serialization.
* *Feature:* Implemented default functions in `Model`.
* *Fix:* Added automatic unbinding of the `Rivets.View` instance in `RivetsHelper`.
* *Fix:* `Model` never applied its default values.

## 0.1.1 (2013-06-27)

* *Fix:* Fixed bug where adding presenters in the `init()` method when extending `Presenter` would not work.

## 0.1.0 (2013-06-26)

* *Feature:* Simple routing using [crossroads.js](http://millermedeiros.github.io/crossroads.js/).
