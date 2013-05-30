# Various object utility methods.
Antifreeze.ObjectUtil = ObjectUtil =
	# Configures the provided using the provided options, optionally filtered by keys.
	# If a key exists on the object in the form of a function, that function will be called with the value.
	# Otherwise a direct assignment will occur.
	configure: (obj, options, keys) ->
		# Optional filter.
		if keys then options = _.pick options, keys
		# Iterate over the keys and their values
		for own key, val of options
			# Ignore undefined keys.
			continue if val is undefined
			# If target is a function, execute it.
			if _.isFunction obj[key]
				obj[key].call obj, val
			# Not a function, just set it
			else
				obj[key] = val
		return