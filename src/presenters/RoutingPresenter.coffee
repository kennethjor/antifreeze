# A specialised presenter designed to accept defined routes to its subpresenters.
# It listens to those routes, updating the `page` attribute on the model.
# This can be used in combination with the `DeckView` to show different views based on routes.
Antifreeze.RoutingPresenter = class RoutingPresenter extends Presenter
	constructor: ->
		# Wait for subpresenters to be added.
		@on "presenterAdded", (event) ->
			data = event.data
			name = data.name
			presenter = data.presenter
			options = data.options
			# Check for route.
			# If no route is present, this presenter implementation has nothing to do.
			route = options.route
			return unless route
			# Attach event handler on route
			route.on "routed", do (name, presenter) => (event) =>
				params = event.data.namedParams
				# Set current page name on presenter.
				@model().set page: name
				# Set param data on subpresenter. @todo implement places
				presenter.model().set params
		super
