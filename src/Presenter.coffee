# Base presenter
#
# ## Local events triggered:
#
# * `presenterAdded`
#
Antifreeze.Presenter = class Presenter
	# Local events.
	Calamity.emitter @prototype
	# Global events.
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
		# Setter.
		if model
			# Auto-construct model.
			if _.isObject(model) and model instanceof Model isnt true
				model = new Model model
			# Store model.
			@_model = model
			# Propagate to view.
			if @_view then @_view.model model
			return
		# Construct default.
		unless @_model then @model {}
		# Getter.
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
			# Lazy-construct the view.
			unless @_view
				@_view = new @_viewConstructor
					model: @model()
					element: @element
				# Add any sub-views we might have.
				for own name, options of @_presenters
					@_view.add name, options.presenter.view()
		return @_view

	# Attaches an event on the view.
	onViewEvent: (event, callback) ->
		@view().on event, _.bind(callback, @)

	# Adds a presenter as a subpresenter using the specified name.
	add: (name, options) ->
		# Create options object.
		options or= {}
		if options instanceof Presenter then options = presenter: options
		presenter = options.presenter
		unless presenter then throw new Error "Presenter not supplied"
		# Store.
		@_presenters[name] = options
		# If view already exists, add subview immediately.
		if @_view then @_view.add name, presenter.view()
		# Fire event.
		@trigger "presenterAdded",
			name: name
			options: options
			presenter: presenter
		return @

	# Returns true if this presenter has an attached subpresenter by the given name.
	has: (name) ->
		return _.has @_presenters, name

	# Returns a subpresenter configuration by name, or undefined if it doesn't exist.
	get: (name) ->
		return @_presenters[name]

