# A `Map` stores values against keys.
# Unlike JavaScript objects, the `Map` is able to contain objects as keys.
Antifreeze.Map = class Map
	Calamity.emitter @prototype

	constructor: ->
		@_items = []

	# Sets a key in the map.
	# If the key already exists, the value will be overwritten.
	# If value was overwritten, the previous value is returned, otherwise null.
	put: (key, val) ->
		# Check if we have the key already.
		index = @_getIndexForKey key
		entry = [key, val]
		returnVal = null
		# Add new.
		if index is false
			@_items.push entry
			# Replace existing.
		else
			oldVal = @_items[index][1]
			@_items[index] = entry
			returnVal = oldVal
		# Fire change event.
		@trigger "change",
			type: "put"
			map: @
			key: key
			value: val
			oldValue: returnVal
		# Return old value if present.
		return returnVal

	# Returns a value by key, or null if not found.
	get: (key) ->
		index = @_getIndexForKey key
		return null if index is false
		return @_items[index][1]

	# Removes a key.
	remove: (key) ->
		index = @_getIndexForKey key
		return null if index is false
		# Remove and return previous value.
		returnVal = @_items.splice(index, 1)[1]
		# Fire change event.
		@trigger "change",
			type: "remove"
			map: @
			key: key
			oldValue: returnVal
		# Return old value.
		return returnVal

	# Returns true if the key exists, false if not.
	hasKey: (key) ->
		return @_getIndexForKey(key) isnt false

	# Returns true if the value exists, false if not.
	hasValue: (val) ->
		return @_getIndexForValue(val) isnt false

	# Iterator.
	each: (fn) ->
		for entry in @_items
			fn.apply @, entry
		return @

	# Returns the number of items in the map.
	length: ->
		return @_items.length

	# Returns a JSON representation of the `Map`.
	# This will return an object with string-representations of the key objects as the index,
	# and the value will be an object in the form `{key:*key*, value:*value*}`.
	toJSON: ->
		json = {}
		@each (key, value) =>
			keyString = @_getStringForKey key
			json[keyString] =
				key: key,
				value: value
		return json

	# Returns the internal array index for the key, or false if the key was not found.
	_getIndexForKey: (key) ->
		for entry, i in @_items
			if entry[0] is key
				return i
		return false

	# Returns the internal array index for the value, or false if the value was not found.
	_getIndexForValue: (val) ->
		for entry, i in @_items
			if entry[1] is val
				return i
		return false

	# Converts a key object to a string.
	_getStringForKey: (key) ->
		if _.isObject key
			if _.isFunction key.toString
				key = key.toString()
		else
			key = ""+key
		throw new Error "Failed to convert key to string" unless _.isString key
		return key