$ = require "jquery"
sinon = require "sinon"
{View, Model, HelperBroker} = require "../antifreeze"

class TestView extends View
	$: $

describe "View", ->
	it "should call the init method during construction", ->
		init = sinon.spy()
		class Test extends TestView
			init: init
		view = new Test
		expect(init.callCount).toBe 1

	it "should accept a model and an element correctly.", ->
		model = new Model
		$element = $ "<div>test</div>"
		view = new TestView
			model: model
			element: $element
		expect(view.model()).toBe model
		expect(view.element()).toBe $element

	it "should auto-construct a model if JSON is passed", ->
		view = new TestView
			model:
				foo: "FOO"
		model = view.model()
		expect(model instanceof Model).toBe true
		expect(model.get "foo").toBe "FOO"
		# Pass a new one.
		view.model
			bar: "BAR"
		newModel = view.model()
		expect(newModel).not.toBe model
		expect(newModel instanceof Model).toBe true
		expect(newModel.get "bar").toBe "BAR"

	it "should provide a make() method for easy element creation", ->
		view = new TestView()
		$element = view.make "span", class: "test", super: "fine", "content"
		expect($element[0].tagName).toBe "SPAN"
		expect($element.attr "class").toBe "test"
		expect($element.attr "super").toBe "fine"
		expect($element.html()).toBe "content"

	it "should create a default element with tag and class", ->
		view = new TestView
			tagName: "div"
			className: "className"
		$element = view.element()
		expect($element.size()).toBe 1
		expect($element[0].tagName).toBe "DIV"
		expect($element.hasClass "className").toBeTruthy()

	it "should trigger a 'newModel' event when given a new model, but not when assigned the same model again", ->
		newModel = sinon.spy()
		model = new Model data: 1
		view = new TestView
			model: model
		view.on "newModel", newModel
		view.model model
		view.model new Model data: 2
		waitsFor (-> newModel.called), "Event never triggered", 100
		runs ->
			expect(newModel.callCount).toBe 1

	it "should trigger a 'newElement' event when given a new element, but not when assigned the same element again", ->
		newElement = sinon.spy()
		$element = $ "<div>1</div>"
		view = new TestView
			element: $element
		view.on "newElement", newElement
		view.element $element
		view.element $ "<div>2</div>"
		waitsFor (-> newElement.called), "Event never triggered", 100
		runs ->
			expect(newElement.callCount).toBe 1

	it "should provide an overridable method '_render', which is called during render.", ->
		view = new TestView()
		sinon.spy view, "_render"
		view.render()
		waitsFor (-> view._render.called), "Render never called", 100
		runs ->
			expect(view._render.callCount).toBe 1

	it "should not render until it is explicitly instructed to do so", ->
		class Test extends TestView
			render: sinon.spy()
		view = new Test
			element: $ "<div></div>"
			model: model: 1
		# Not called during construction
		expect(view.render.callCount).toBe 0
		# Not called during any new assignment
		view.element view.make()
		expect(view.render.callCount).toBe 0
		view.model new Model model: 2

	it "should execute render calls in a deferred manner, delegating to a private method", ->
		view = new TestView
		sinon.spy view, "_render"
		view.render()
		expect(view._render.called).toBeFalsy()
		waitsFor (-> view._render.called), "view.render never called", 100
		runs ->
			expect(view._render.called).toBeTruthy()

	it "should handle multiple render commands and only ever tricker one at a time", ->
		view = new TestView
		sinon.spy view, "_render"
		view.render()
		view.render()
		waitsFor (-> view._render.called), "view.render never called", 100
		runs ->
			expect(view._render.callCount).toBe 1

	it "should by default render a provided template with model data", ->
		templateData = null
		template = sinon.spy (data) ->
			templateData = data
			return "TESTHTML"
		class Test extends TestView
			template: template
		view = new Test
			model: new Model
				foo: "FOO"
		view.render()
		waitsFor (-> template.called), "Template never called", 100
		runs ->
			expect(template.callCount).toBe 1
			expect(templateData.foo).toBe "FOO"
			expect(view.element().html()).toBe "TESTHTML"

	it "should hide and show its element", ->
		view = new TestView
		expect(view.element().is ":visible").toBeTruthy()
		view.hide()
		expect(view.element().is ":visible").toBeFalsy()
		view.show()
		expect(view.element().is ":visible").toBeTruthy()

	it "should respond to render commands and trigger events and call render appropriately", ->
		beforeRender1 = sinon.spy()
		beforeRender2 = sinon.spy()
		afterRender1 = sinon.spy()
		afterRender2 = sinon.spy()
		view = new TestView()
		sinon.spy view, "_render"
		view.on "beforeRender", beforeRender1
		view.on "beforeRender", beforeRender2
		view.on "afterRender", afterRender1
		view.on "afterRender", afterRender2
		view.render()
		waitsFor (-> beforeRender1.called), "beforeRender1 never called", 100
		waitsFor (-> beforeRender2.called), "beforeRender2 never called", 100
		waitsFor (-> view._render.called), "view.render never called", 100
		waitsFor (-> afterRender1.called), "afterRender1 never called", 100
		waitsFor (-> afterRender2.called), "afterRender2 never called", 100
		runs ->
			expect(beforeRender1.callCount).toBe 1
			expect(beforeRender2.callCount).toBe 1
			expect(view._render.callCount).toBe 1
			expect(afterRender1.callCount).toBe 1
			expect(afterRender2.callCount).toBe 1
			expect(beforeRender1.calledBefore beforeRender2).toBeTruthy()
			expect(beforeRender2.calledBefore view._render).toBeTruthy()
			expect(afterRender1.calledAfter view._render).toBeTruthy()
			expect(afterRender2.calledAfter afterRender1).toBeTruthy()

	it "should proxy Dom events through a callback", ->
		template = sinon.spy ->
			return "<button></button>"
		click = sinon.spy()
		callback = sinon.spy()
		class Test extends TestView
			template: template
		view = new Test()
		view.on "button:click", click
		view.on "afterRender", ->
			@proxyDomEvent "button", "click", "button:click", callback
		view.render()
		waitsFor (-> template.called), "Template never run", 100
		runs -> view.element().find("button").click()
		waitsFor (-> click.called), "Click never called", 100
		runs ->
			expect(click.callCount).toBe 1
			expect(callback.callCount).toBe 1

	it "should init a HelperBroker with itself as the context", ->
		helperContext = null
		viewTestHelper = sinon.spy -> helperContext = @
		HelperBroker.add "viewTestHelper", viewTestHelper
		view = new TestView
		expect(typeof view.helpers).toBe "object"
		expect(view.helpers instanceof HelperBroker).toBe true
		view.helpers.viewTestHelper()
		expect(helperContext.view).toBe view
		HelperBroker.add "viewTestHelper", undefined