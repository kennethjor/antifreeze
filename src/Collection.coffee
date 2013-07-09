Antifreeze.Collection = class Collection
	Calamity.emitter @prototype

	constructor: ->
		@_items = []

	# Adds an element to the collection.
	# Returns true if the element was added.
	add: (obj) ->
		@_items.push obj
		# Fire change event.
		@trigger "change",
			type: "add"
			map: @
			value: obj
		return true

	# Removes a element from the collection.
	# Returns true if the collection was altered by the remove.
	remove: (obj) ->
		index = @_getIndex(obj)
		return false if index is false
		# Remove element.
		oldVal = @_items.splice(index, 1)[1]
		# Fire change event.
		@trigger "change",
			type: "remove"
			map: @
			oldValue: oldVal
		# Return old value.
		return true

	# Returns true of this collection contains the supplied element.
	contains: (obj) ->
		return @_getIndex(obj) isnt false

	# Returns the sizxe of the collection.
	size: (obj) ->
		return @_items.length

	# Iterator.
	each: (fn) ->
		for entry in @_items
			fn.apply @, [entry]
		return @

	toJSON: ->
		json = []
		for o in @_items
			json.push o
		return json

	# Returns the internal array index for the object, or false if it not found.
	_getIndex: (obj) ->
		for entry, i in @_items
			if entry is obj
				return i
		return false
