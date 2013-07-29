# Changelog

## 0.3.0 (dev)
* *API change:* Default model functions are supplied the values object rather than as context.
* *API change:* Model serialization now only encodes the `id` set using `id()`.
* *API change:* Removed the `serialize()` function from `Model`. This should be explicitly implemented.
* *Feature:* Implemented `Model.clone()` for object cloning.
* *Feature:* Implemented `Model.each()` for object iteration.
* *Feature:* Implemented `Map.clone()`, which is just a proxy for the cosntructor.
* *Feature:* Added ability for supplying other `Model` instances to `Model.set()`.
* *Feature:* Added `Persistor` class.
* *Feature:* Added support for `relations` configuration on `Model`.
* *Fix:* Default values would cause a crash when model were contructed without initial values.

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
