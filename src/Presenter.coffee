Calamity = require "calamity"

# Base presenter.
Antifreeze.Presenter = class Presenter
	# Global event bus with `_subscribe()` and `_publish()`.
	Calamity.proxy @prototype
	# Options.
	classOptions = "view,model,element".split ","

	constructor: (options) ->
		options or= {}
		# Configure.
		ObjectUtil.configure @, options or {}, classOptions
		# Complain about missing view.
		unless options.view then throw new Error("No view provided")
		# Sub presenter collection.
		@_presenters = {}
		@init()

	init: ->
		# Empty.

	# Sets or gets the model.
	model: (model) ->
		if model
			# Auto-construct model.
			if _.isObject(model) and model instanceof Model isnt true
				model = new Model model
			# Store model.
			@_model = model
			# Propagate to view.
			if @_view then @_view.model model
			return
		return @_model

	# Sets the view constructor or gets the view instance.
	view: (view) ->
		if view
			unless _.isFunction view then throw new Error "View must be a constructor."
			#newView = @_viewConstructor isnt @_view
			@_viewConstructor = view
			@_view = undefined
			return
		else
			# Lazy-construct the view
			unless @_view
				@_view = new @_viewConstructor
					model: @model()
					element: @element
				# Add any sub-views we might have
				for own name, presenter of @_presenters
					@_view.add name, presenter.view()
		return @_view

	# Attaches an event on the view.
	onViewEvent: (event, callback) ->
		@view().on event, _.bind(callback, @)

	# Adds a presenter as a subpresente using the specified name.
	add: (name, presenter) ->
		@_presenters[name] = presenter
		# If view already exists, add subview immediately
		if @_view then @_view.add name, presenter.view()
		return @

	# Returns true if this presenter has an attached subpresenter by the given name.
	has: (name) ->
		return _.has @_presenters, name

	# Returns a subpresenter by name, or undefined if it doesn't exist.
	get: (name) ->
		return @_presenters[name]

