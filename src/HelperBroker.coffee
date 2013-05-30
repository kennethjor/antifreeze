# The `HelperBroker` manages a number of helpers for the views.
# Helpers are registered with the `add()` method.
# Broker instances for specified contexts are retrieved using the `get()` method.
# This class should never be cosntructed directly.
Antifreeze.HelperBroker = class HelperBroker
	# Constructor.
	constructor: (view) ->
		# Transfer helpers.
		initBroker @, view

# Adds a helper.
helpers = {}
HelperBroker.add = (name, helper) ->
	helpers[name] = helper
	return @

initBroker = (broker, view) ->
	for own name, helper of helpers
		continue if helper is undefined
		# Create context.
		context =
			view: view
		# 1st level.
		if _.isFunction helper
			broker[name] = _.bind helper, context
		else if _.isObject helper
			broker[name] = {}
		else
			throw new Error "Helper must be either function or object, " + typeof helper + " supplied"
		# Attach bound helper to context.
		context.helper = broker[name]
		# 2nd level.
		continue if _.isEmpty helper
		for own subName, subHelper of helper
			continue unless typeof subHelper is "function"
			broker[name][subName] = _.bind subHelper, context
	return undefined

# Creates and returns broker instance for a specified view.
HelperBroker.getForView = (view) ->
	return new HelperBroker view
