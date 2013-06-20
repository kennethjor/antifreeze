class Router extends Antifreeze.Router
	initRoutes: () ->
		console.log "init routes"
		@add "home",
			name: "homePage"
		@add "archive/{date}",
			name: "archivePage"
		@add "article/{id}/:section:/:seo*:",
			name: "articlePage"

class HomePresenter extends Antifreeze.Presenter
	init: ->

class HomeView extends Antifreeze.View


$ ->
	# Create and attach RootPresenter
	#root = new Antifreeze.RootPresenter

	# Init router
	router = new Router()
	router.subscribe Router.EVENT_ROUTED, (event) ->
		console.log Router.EVENT_ROUTED, event
	router.attach()


