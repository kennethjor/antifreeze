# Base view from which all other views are built.
#
# ## Events child views:
#
# * `newModel`
# * `newElement`
# * `beforeRender`
# * `afterRender`
# * `beforeShow` - NOT IMPLEMENTED
# * `afterShow` - NOT IMPLEMENTED
# * `beforeHide` - NOT IMPLEMENTED
# * `afterHide` - NOT IMPLEMENTED
#
Antifreeze.View = class View
	# Local event bus with `on()` and `_trigger()`.
	Calamity.emitter @prototype
	# Options.
	classOptions = "tagName,className,model,element".split ","

	# Default tag name for default elements.
	tagName: "div"

	constructor: (options) ->
		options or= {}
		# Attach custom jQuery if supplied.
		if options.$?
			@$ = options.$
		# Check if we have one set on the type.
		else if @$
			# Nothing
		# Finally try and grab is from the environment.
		else
			if typeof $ is "undefined" or not _.isFunction $
				throw new Error "jQuery not found"
			@$ = $

		# Configure.
		ObjectUtil.configure @, options or {}, classOptions
		# Init helpers.
		@helpers = new HelperBroker @
		# Subview container.
		@_views = {}
		# Whether a render has been scheduled or not.
		@_renderScheduled = false
		# Allow subclasses to initialise.
		@init()

	# Initialization methods.
	# Extends to provide your own init code.
	init: ->
		# Empty.

	# Overridable render method.
	# Default implementation simply renders the given template, if present.
	_render: ->
		@element().html @_callTemplate()

	# Sets or gets the model.
	model: (model) ->
		# Setter.
		if model
			# Auto-construct model.
			if _.isObject(model) and model instanceof Discrete.Model isnt true
				model = new Discrete.Model model
			# Trigger newModel event.
			if model isnt @_model then @trigger "newModel"
			# Store model.
			@_model = model
			return
		# Getter.
		return @_model

	# Sets or gets the element.
	element: (element) ->
		# Setter.
		if element
			if element isnt @_element then @trigger "newElement"
			# Make sure it's a jQuery object
			element = @$ element unless element.jquery
			@_element = element
			return
		# Create default element.
		unless @_element
			element = @make @tagName,
				class: @className
			@element element
		# Getter.
		return @_element

	# Utility method for creating elements.
	make: (tag="div", attributes, content) ->
		$element = @$ "<"+tag+"></"+tag+">"
		if _.isObject attributes then $element.attr attributes
		if content
			if _.isString content then $element.html content
			if content.jquery then $element.append content
		return $element

	# Proxies an `domEvent` on elements matching `selector` to the local `viewEvent`,
	# optionally channeled through the supplied callback.
	proxyDomEvent: (selector, domEvent, viewEvent, callback) ->
		# Get element.
		$el = selector
		unless $el.jquery
			$el = @element().find selector
		return false if $el.length is 0
		# Create handler.
		handler = (domEvent) ->
			# Event data.
			data =
				view: @
			# Pass event data through optional callback.
			if _.isFunction callback
				data = callback(data)
			# Trigger locally.
			@trigger viewEvent, data
		# Bing to local view.
		bound = _.bind handler, @
		# Set event on element.
		$el[domEvent](bound)
		return $el

	# Executes a deferred render.
	# Do not override this method, instead use `_render()`.
	render: () ->
		return if @_renderScheduled
		@_renderScheduled = true
		_.defer => @trigger "beforeRender"
		_.defer => @_render()
		_.defer => @trigger "afterRender"
		_.defer => @_renderScheduled = false
		return

	# Executes the internal template if any.
	_callTemplate: () ->
		return undefined unless _.isFunction @template
		# Export model data to JSON.
		data = @model() or {}
		if _.isFunction data.toJSON
			data = data.toJSON()
		html = @template(data)
		return html

	# Adds a view as a subview using the specified name.
	add: (name, view) ->
		@_views[name] = view
		view.hide()
		return @

	# Returns true if this view has an attached subview by the given name.
	has: (name) ->
		return _.has @_views, name

	# Returns a subview by name, or undefined if it doesn't exist.
	get: (name) ->
		return @_views[name]

	# Hides the view.
	hide: ->
		@element().hide()

	# Shows the view.
	show: ->
		@element().show()

