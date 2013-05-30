Calamity = require "calamity"

Antifreeze.Model = class Model
	Calamity.emitter @prototype

	# Default values are assigned automatically.
	defaults: {}

	# Constructor.
	constructor: (values) ->
		# Prepare internal containers.
		@_values = {}
		# Add default values to initial values.
		_.defaults values, @defaults
		# Set values.
		@set values

	# Sets one or more values.
	# Can be called with a key and value, or with an object.
	set: (keyOrObj, val) ->
		return unless keyOrObj
		# Convert to object.
		obj = keyOrObj
		unless _.isObject obj
			o = {}
			o[obj] = val
			obj = o
		# Prepare container to hold old values for changed keys
		triggers = {}
		# Iterate over object.
		for own key, val of obj
			# Save old value.
			triggers[key] = @_values[key]
			# Set value.
			@_values[key] = val
		# Trigger change events.
		@_triggerChanges triggers
		return @

	# Executes change events.
	_triggerChanges: (keys) ->
		# Fire main trigger.
		@trigger "change",
			model: @
#			keys: _.keys keys
		for own key, oldVal of keys
			event = "change:#{key}"
			@trigger event,
				model: @
#				key: key
#				oldVal: val
				value: @get key

	# Returns a value on the object.
	get: (key) ->
		return @_values[key]

	# Returns a list of keys.
	keys: ->
		return _.keys @_values

	# Serializes the model into a plain JSON object.
	toJSON: ->
		json = _.clone @_values
		for own key, val of json
			if val and typeof val.toJSON is "function"
				json[key] = val.toJSON()
		return json
