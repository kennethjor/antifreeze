# Changelog

## 0.4.0 (dev)
* *API change:* Removed all modelling code into a separate project called `discrete`.
* *Fix:* Templates are now called with the view as their `this` value.

## 0.3.0 (2013-07-30)
* *API change:* Default model functions are supplied the values object rather than as context.
* *API change:* Model serialization now only encodes the `id` set using `id()`.
* *API change:* Removed the `serialize()` function from `Model`. This should be explicitly implemented.
* *Feature:* Implemented `Model.clone()` for object cloning.
* *Feature:* Implemented `Model.each()` for object iteration.
* *Feature:* Implemented `Map.clone()`, which is just a proxy for the constructor.
* *Feature:* Added ability for supplying other `Model` instances to `Model.set()`.
* *Feature:* Added `Persistor` class.
* *Feature:* Added support for `relations` configuration on `Model`.
* *Fix:* Default values would cause a crash when model were constructed without initial values.

## 0.2.1 (2013-07-19)
* *Fix:* Thorough testing and related fixes to the `Collection`, `Set`, and `Map` classes.

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
