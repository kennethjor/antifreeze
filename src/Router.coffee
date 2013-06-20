Antifreeze.Router = class Router
	Calamity.proxy @prototype
	EVENT_ROUTED = @EVENT_ROUTED = "antifreeze:router.routed"

	constructor: ->
		@_attached = false
		@_routes = []
		@_crossroads = crossroads.create()
		@_crossroads.routed.add _.bind(@_crossroadsRouted, @)

		@initRoutes()

	# Initialises the internal routes.
	# Override to implement.
	initRoutes: () ->
		# Empty

	# Adds a routing pattern to the routing list.
	add: (pattern, options) ->
		options or= {}
		# Construct new `Route`.
		route = new Route pattern, options
		# Create route in Crossroads and add to route.
		crossroadsRoute = @_crossroads.addRoute pattern
		route._crossroads = crossroadsRoute
		# Extract paramter IDs
		route._paramIds = @_crossroads.patternLexer.getParamIds(pattern)
		# Add `Route` and return
		@_routes.push route

		return route

	# Internal handler for when Crossroads reports a routing occured.
	_crossroadsRouted: (hash, event) ->
		params = event.params
		crossroadsRoute = event.route
		# Find route
		route = null
		for r in @_routes
			if crossroadsRoute is r._crossroads
				route = r
				break
		# Unknown route, pretend nothing happened @todo we should probably tell the application
		return if route is null
		# @todo implement places
		# Assemble values with IDs
		namedParams = _.object route._paramIds, params
		# Publish event
		@publish EVENT_ROUTED,
			hash: hash
			route: route
			params: params
			namedParams: namedParams
		return

	# Attaches the router to the browser.
	attach: () ->
		# Only attach once.
		return if @_attached
		# Statically import Crossroads instance and create event handler
		crossroads = @_crossroads
		parseHash = (hash) -> crossroads.parse hash
		# Add event handler to Hasher.
		Hasher.initialized.add parseHash
		Hasher.changed.add parseHash
		# Initialize Hasher.
		Hasher.init()

		@_attached = true
		return
