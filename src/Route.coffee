Antifreeze.Route = class Route
	# Local event bus with `on()` and `trigger()`.
	Calamity.emitter @prototype

	constructor: (pattern, @options) ->
		@options or= {}
		# Check if pattern is a string.
		unless _.isString pattern
			throw new Error "Pattern must be a string, " + (typeof pattern) + " supplied"

