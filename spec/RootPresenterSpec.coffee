{RootPresenter, Presenter} = require "../antifreeze"

describe "RootPresenter", ->
	it "should handle routes to presenters", ->
		root = new RootPresenter
		router = root._router
		presenter1 = new Presenter
		presenter2 = new Presenter
		root.add "first/{id}", presenter1
		root.add "second/{id}", presenter2
		presenter1id = null
		presenter2id = null
		presenter1routed = sinon.spy (event) ->
			presenter1id = event.data.parameters.id
		presenter2routed = sinon.spy (event) ->
			presenter2id = event.data.parameters.id
		router.route "first/10"
		waitsFor (-> presenter1routed.called), "Presenter 1 handler never called", 100
		runs ->
			expect(presenter1id).toBe 10
			router.route "second/20"
		waitsFor (-> presenter2routed.called), "Presenter 2 handler never called", 100
		runs ->
			expect(presenter2id).toBe 20
			expect(presenter1routed.callCount).toBe 1
			expect(presenter2routed.callCount).toBe 1
