crossroads = require "crossroads"
Calamity = require "calamity"

Antifreeze.Router = class Router
	# Local event bus with `on()` and `trigger()`.
	Calamity.emitter @prototype

	constructor: ->
		@_routes = []
		@_crossroads = crossroads.create()

	# Adds a `Route` to the routing list.
	add: (options) ->
		# Conveerts strings to options, assuming string is the pattern.
		if _.isString options
			options = pattern: options
		# Convert object to `Route` assuming object is an options object.
		if _.isObject options
			options = new Route options
		# Check
		unless options instanceof Route is false
			throw new Error "No Route provided or constructed"
		# Add route to Crossroads
		crossroadsRoute = @_crossroads.addRoute options.pattern
		options._crossroads = crossroadsRoute
		# Add `Route` and return
		@_routes.push options
		return options
