Antifreeze.Model = class Model
	Calamity.emitter @prototype

	# Default values to be assigned automatically.
	# Any functions defined here will be executed and their return values will be used as the default.
	# These functions are executed once per needed default value, and they take the current values object as their only argument.
	defaults: {}

	# Constructor.
	constructor: (values) ->
		# ID.
		@_id = null
		if values?.id?
			@id values.id
			values.id = undefined
		# Prepare internal containers.
		@_values = {}
		# Populate default values.
		values = @_defaults values
		# Set values.
		@set values

	# Populates default values.
	_defaults: (values) ->
		for own key, val of @defaults
			# Ignore existing values.
			continue if values[key]?
			# Execute default function.
			if _.isFunction val
				values[key] = val values
			else
				values[key] = val
		return values

	# ID getter/setter.
	id: (id) ->
		if id?
			@_id = id
		return @_id

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

	# Iterator.
	each: (fn) ->
		for key, val of @_values
			fn.apply @, [key, val]
		return @

	# Serializes the model into a plain JSON object.
	toJSON: ->
		json = _.clone @_values
		# Set ID if we have it.
		if @_id?
			json.id = @_id
		# Otherwise make sure the serialized form does not contain an ID.
		else
			delete json.id

		return json

	# Creates a clone of this model.
	# Extend to properly implement deep cloning where needed.
	# `baseModel` can be used when extending to provide a base model object to clone into.
	clone: (baseModel = null) ->
		baseModel or= new Model
		baseModel.id @id()
		@each (key, val) ->
			baseModel.set key, val
		return baseModel

	# Serializes the model for persistent storage.
	# By default this returns a JSON object, but feel free to extend.
	serialize: ->
		return @toJSON()