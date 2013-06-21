$ ->
	# Create router.
	router = new Antifreeze.Router

	# Attach a presenter on the root body element.
	# The `DeckView` shows only one of its subviews at a time.
	root = new Antifreeze.RoutingPresenter
		element: document.body
		view: Antifreeze.DeckView

	# Create home presenter.
	root.add "home",
		route: router.add "home"
		presenter: new Antifreeze.Presenter
			view: class HomeView extends Antifreeze.View
				template: () -> "<h1>Home</h1><p>Templates are just functions.</p>"

	# Create article presenter.
	root.add "article",
		route: router.add "article/{id}"
		presenter: new Antifreeze.Presenter
			view: class ArticleView extends Antifreeze.View
				template: (data) -> "<h1>Article #{data.id}</h1><p>Templates also accept data from the model.</p>"

	# Render the root view.
	root.view().render()

	# Attach router to browser.
	_.defer -> router.attach()

	# Set default page
	if _.isEmpty window.location.hash
		root.model().set "page", "home"

