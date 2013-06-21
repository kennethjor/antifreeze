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
	window.root = root

	# Create home presenter.
	root.add "home", new Antifreeze.Presenter
		#route: router.add "home"
		view: class HomeView extends Antifreeze.View
			template: () -> "<h1>Home</h1><p>Templates are just functions.</p>"
	router.add "home",
		name: "home"

	# Create article presenter.
	root.add "article", new Antifreeze.Presenter
		#route: router.add "article/{id}"
		view: class ArticleView extends Antifreeze.View
			template: (data) -> "<h1>Article #{data.id}</h1><p>Templates also accept data from the model.</p>"
	router.add "article/{id}",
		name: "article"

	# Create handler to react to new routes being activated
	router.on "routed", (event) ->
		# Import route name option.
		page = event.data.route.options.name
		console.log event
		# Import named parameters.
		params = event.data.namedParams
		# Pass parameters to sub presenter.
		if params
			subPresenter = root.get(page)
			if subPresenter
				subPresenter.presenter.model().set params
		# Set displayed page.
		root.model().set "page", page

	# Render the root view.
	root.view().render()

	# Attach router to browser.
	router.attach()
