$ = require "jquery"
sinon = require "sinon"
{Presenter, View, Model} = require "../antifreeze"

class TestView extends View
	constructor: (o) ->
		o or= {}
		o.$ = $
		super o

class TestPresenter extends Presenter

describe "Presenter", ->
	it "should complain if a view is not supplied", ->
		func = ->
			new TestPresenter()
		expect(func).toThrow()

	it "should call the init method during construction", ->
		init = sinon.spy()
		class Test extends TestPresenter
			init: init
		new Test
			view: TestView
		expect(init.callCount).toBe 1

	it "should not construct its view until its needed", ->
		Test = sinon.spy TestView
		presenter = new TestPresenter
			view: Test
		expect(Test.callCount).toBe 0
		expect(presenter.view() instanceof TestView).toBe true
		expect(Test.callCount).toBe 1

	it "should accept model and view constructor correctly", ->
		model = new Model
		presenter = new TestPresenter
			model: model
			view: TestView
		expect(presenter._viewConstructor).toBe TestView
		expect(presenter.model()).toBe model

	it "should auto-construct a model if JSON is passed", ->
		presenter = new Presenter
			view: TestView
			model:
				foo: "FOO"
		model = presenter.model()
		expect(model instanceof Model).toBe true
		expect(model.get "foo").toBe "FOO"
		# Pass a new one.
		presenter.model
			bar: "BAR"
		newModel = presenter.model()
		expect(newModel).not.toBe model
		expect(newModel instanceof Model).toBe true
		expect(newModel.get "bar").toBe "BAR"

	it "should construct view and share its model and element with the view", ->
		model = new Model
		$element = $ "<div></div>"
		presenter = new TestPresenter
			model: model
			view: TestView
			element: $element
		view = presenter.view()
		expect(view instanceof TestView).toBeTruthy()
		expect(view.model()).toBe model
		expect(view.element()).toBe $element

	it "should not cause the view to be rendered by default", ->
		render = sinon.spy()
		class Test extends TestView
			_render: render
		presenter = new TestPresenter
			view: Test
		view = presenter.view()
		expect(render.called).toBe false

	it "should propagate new models to its view", ->
		model1 = new Model data: "foo"
		model2 = new Model data: "bar"
		presenter = new TestPresenter
			model: model1
			view: TestView
		view = presenter.view()
		expect(view.model()).toBe model1
		presenter.model model2
		expect(view.model()).toBe model2

	it "should provide a helper function to tie into view events", ->
		presenter = new Presenter
			view: TestView
		view = presenter.view()
		callback = sinon.spy()
		presenter.onViewEvent "test:event", callback
		view.trigger "test:event"
		waitsFor (-> callback.called), "Callback never called", 100
		runs ->
			expect(callback.callCount).toBe 1

	describe "and sub-presenters", ->

		it "should be accepted and stored by name", ->
			presenter = new TestPresenter
				view: TestView
			subPresenter = new TestPresenter
				view: TestView
			presenter.add "name", subPresenter
			expect(presenter.get("name").presenter).toBe subPresenter

		it "should have their views passed on as named sub-views when the view is first constructed", ->
			View1 = sinon.spy TestView
			View2 = sinon.spy TestView
			presenter = new TestPresenter
				view: View1
			subPresenter = new TestPresenter
				view: View2
			# Add sub-presenter
			presenter.add "name", subPresenter
			# Get master view
			view = presenter.view()
			# Both views should now have been created
			expect(View1.callCount).toBe 1
			expect(View2.callCount).toBe 1
			# And subPresenter's view should be added to master view
			expect(view.get "name").toBe subPresenter.view()
			# Any additional sub presenters' views should also be added
			View3 = sinon.spy TestView
			subPresenter2 = new TestPresenter
				view: View3
			presenter.add "another", subPresenter2
			expect(View3.callCount).toBe 1
			expect(view.get "another").toBe subPresenter2.view()
