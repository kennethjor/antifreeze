$ ->
	# Create router.
	router = new Antifreeze.Router

	# Attach a presenter on the root body element.
	# The `DeckView` shows only one of its subviews at a time.
	root = new Antifreeze.Presenter
		element: document.body
		view: Antifreeze.DeckView
		model:
			page: "home"

	# Create home presenter.
	root.add "home", new Antifreeze.Presenter
		view: class HomeView extends Antifreeze.View
			template: () -> "<h1>Home</h1><p>Templates are just functions.</p>"
	# Create home route.
	router.add "home",
		name: "home"

	# Create article presenter.
	root.add "article", new Antifreeze.Presenter
		view: class ArticleView extends Antifreeze.View
			template: (data) -> "<h1>Article #{data.id}</h1><p>Templates also accept data from the model.</p>"
	# Create article route.
	router.add "article/{id}",
		name: "article"

	# Create handler to react to new routes being activated
	router.on "routed", (event) ->
		# Import route name option.
		page = event.data.route.options.name
		# Import named parameters.
		params = event.data.namedParams
		# Pass parameters to sub presenter.
		if params
			subPresenter = root.get page
			if subPresenter
				subPresenter.model().set params
		# Set displayed page.
		root.model().set "page", page

	# Render the root view.
	root.view().render()

	# Attach router to browser.
	router.attach()
