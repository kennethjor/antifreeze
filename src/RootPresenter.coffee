# A specialised presenter designed to be attached to the body element itself and handle global routing.
Antifreeze.RootPresenter = class RootPresenter extends Presenter
	constructor: (options) ->
		options or= {}
		# Fetch and attach body, if available
		unless options.element
			body = document.getElementsByTagName("body")
			if body and body.length > 0
				options.element = body[0]
		# Call super constructor.
		super options

	#