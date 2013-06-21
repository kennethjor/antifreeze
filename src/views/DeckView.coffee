# `DeckView` is a specialised `View` which only ever shows one of its subviews.
# The name of the shown subview is controlled by the `page` attribute on the model.
Antifreeze.DeckView = class DeckView extends View
	init: ->
		@model().on "change:page", _.bind(@_pageChange, @)

	add: (name, view) ->
		super
		@element().append view.element()
		view.hide()
		if name is @model().get "page"
			view.render()
			view.show()

	# `model.change:page` event handler.
	_pageChange: (event) ->
		page = event.data.value
		for own name, view of  @_views
			if name is page
				view.render()
				view.show()
			else
				view.hide()
